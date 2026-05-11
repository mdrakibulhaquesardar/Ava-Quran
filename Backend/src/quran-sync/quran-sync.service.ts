import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { AuthService } from '../auth/auth.service';
import { firstValueFrom } from 'rxjs';
import { AxiosError } from 'axios';

@Injectable()
export class QuranSyncService {
  private readonly baseSyncUrl: string;
  private readonly clientId: string;

  constructor(
    private readonly httpService: HttpService,
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
    private readonly authService: AuthService,
  ) {
    // Fallback to standard pre-live user API endpoint
    this.baseSyncUrl = this.configService.get<string>('Quran_USER_API_BASE') || 'https://apis-prelive.quran.foundation/auth/v1';
    this.clientId = this.configService.get<string>('QURAN_CLIENT_ID') || '';
  }

  private async getActiveToken(userId: string): Promise<string | null> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { quranAccessToken: true, quranTokenExpiresAt: true },
    });

    if (!user || !user.quranAccessToken) {
      return null;
    }

    // Check if expired (with 5-minute buffer)
    if (user.quranTokenExpiresAt && new Date() >= new Date(user.quranTokenExpiresAt.getTime() - 5 * 60 * 1000)) {
      console.log(`[Sync] Token nearing expiration for \${userId}, triggering refresh.`);
      return this.authService.refreshUserQuranToken(userId);
    }

    return user.quranAccessToken;
  }

  /**
   * Generic authenticated wrapper that tries to push, and retries once if expired (401).
   */
  private async makeAuthenticatedRequest(userId: string, method: 'post' | 'delete', endpoint: string, data?: any) {
    let token = await this.getActiveToken(userId);
    if (!token) return; // User not linked to Quran.Foundation account. Silently ignore sync.

    const makeCall = (t: string) => {
      const url = `\${this.baseSyncUrl}\${endpoint}`;
      const headers = {
        'x-auth-token': t,
        'x-client-id': this.clientId,
      };
      if (method === 'post') {
        return firstValueFrom(this.httpService.post(url, data, { headers }));
      } else {
        return firstValueFrom(this.httpService.delete(url, { headers, data }));
      }
    };

    try {
      await makeCall(token);
    } catch (error) {
      const isAuthError = (error as AxiosError)?.response?.status === 401;
      if (isAuthError) {
        console.log(`[Sync] Received 401 for \${userId}, attempting dynamic token refresh retry...`);
        token = await this.authService.refreshUserQuranToken(userId);
        if (token) {
          try {
            await makeCall(token); // Retry
            console.log(`[Sync] Retry successful for \${userId}.`);
            return;
          } catch (retryErr) {
            console.error(`[Sync] Retry failed for \${userId}:`, retryErr.message);
          }
        }
      } else {
        console.error(`[Sync] Upstream API returned non-401 error:`, (error as AxiosError)?.response?.data || error.message);
      }
    }
  }

  async syncReflectionToNotes(userId: string, ayahKey: string, content: string) {
    // The official Notes API expects: { body: string, ranges: ["1:1-1:1"] }
    const payload = {
      body: content,
      ranges: [`\${ayahKey}-\${ayahKey}`],
      attachedEntities: [
        {
          entityType: 'reflection',
          entityMetadata: { source: 'Ava Quran Backend Sync' },
        },
      ],
    };
    
    // Wait for request, fire and forget internally to avoid blocking the API response.
    // Though for reliability, it runs async.
    this.makeAuthenticatedRequest(userId, 'post', '/notes', payload)
      .then(() => console.log(`[Sync] Successfully synced reflection for ayah \${ayahKey} to cloud.`))
      .catch(e => console.error('[Sync] Note sync failed:', e.message));
  }

  async syncCollectionAyahToBookmark(userId: string, ayahKey: string) {
    // Parse ayahKey "1:5" -> key=1, verseNumber=5
    const parts = ayahKey.split(':');
    if (parts.length !== 2) return;
    
    const payload = {
      type: 'ayah',
      key: parseInt(parts[0], 10),
      verseNumber: parseInt(parts[1], 10),
    };

    this.makeAuthenticatedRequest(userId, 'post', '/collections/__default__/bookmarks', payload)
      .then(() => console.log(`[Sync] Successfully synced bookmark for ayah \${ayahKey} to cloud.`))
      .catch(e => console.error('[Sync] Bookmark sync failed:', e.message));
  }
}
