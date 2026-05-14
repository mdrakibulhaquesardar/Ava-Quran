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
    if (!token) {
      console.log(`[Sync] Skipping sync for user \${userId}: No active Quran.Foundation token cached.`);
      return;
    }

    const makeCall = (t: string) => {
      const url = `${this.baseSyncUrl}${endpoint}`;
      const headers = {
        'x-auth-token': t,
        'x-client-id': this.clientId,
      };
      console.log(`[Sync Debug] Initiating ${method.toUpperCase()} request to: ${url}`);
      if (method === 'post') {
        return firstValueFrom(this.httpService.post(url, data, { headers }));
      } else {
        return firstValueFrom(this.httpService.delete(url, { headers, data }));
      }
    };

    try {
      const response = await makeCall(token);
      console.log(`[Sync SUCCESS] URL: ${endpoint} | Status: ${response.status}`);
    } catch (error) {
      const isAuthError = (error as AxiosError)?.response?.status === 401;
      if (isAuthError) {
        console.log(`[Sync] Received 401 for ${userId}, attempting dynamic token refresh retry...`);
        token = await this.authService.refreshUserQuranToken(userId);
        if (token) {
          try {
            const retryRes = await makeCall(token); // Retry
            console.log(`[Sync RETRY SUCCESS] URL: ${endpoint} | Status: ${retryRes.status}`);
            return;
          } catch (retryErr) {
            console.error(`[Sync RETRY FAILED] URL: ${endpoint} | Status: ${retryErr.response?.status} | Error: ${retryErr.message}`);
            throw retryErr;
          }
        } else {
          throw new Error('Token refresh returned null during retry.');
        }
      } else {
        const axiosErr = error as AxiosError;
        const errorPayload = axiosErr?.response?.data;
        console.error(
          `[Sync ERROR] URL: ${endpoint} | Status: ${axiosErr?.response?.status} | Details:`,
          errorPayload || axiosErr.message
        );
        throw error;
      }
    }
  }

  async syncReflectionToNotes(userId: string, ayahKey: string, content: string) {
    // The official Notes API expects: { body: string, ranges: ["1:1-1:1"] }
    const payload = {
      body: content,
      ranges: [`${ayahKey}-${ayahKey}`],
      attachedEntities: [
        {
          entityType: 'reflection',
          entityMetadata: { source: 'Ava Quran Backend Sync' },
        },
      ],
    };
    
    console.log(`[Sync] Attempting to sync Reflection for ${ayahKey}...`);
    this.makeAuthenticatedRequest(userId, 'post', '/notes', payload)
      .catch(e => console.error('[Sync] Note sync sequence failed internally.'));
  }

  async syncCollectionAyahToBookmark(userId: string, ayahKey: string) {
    // Parse ayahKey "1:5" -> key=1, verseNumber=5
    const parts = ayahKey.split(':');
    if (parts.length !== 2) return;
    
    const payload = {
      type: 'ayah',
      key: parseInt(parts[0], 10),
      verseNumber: parseInt(parts[1], 10),
      mushafId: 1, // Standard Mushaf
    };

    console.log(`[Sync] Attempting to sync Bookmark for ${ayahKey} with mushafId: 1...`);
    this.makeAuthenticatedRequest(userId, 'post', '/collections/__default__/bookmarks', payload)
      .catch(e => console.error('[Sync] Bookmark sync sequence failed internally.'));
  }
}
