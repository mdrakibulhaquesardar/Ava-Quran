import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { firstValueFrom } from 'rxjs';
import { RedisService } from '../redis/redis.service';

@Injectable()
export class QuranService {
  // Official Foundation APIs
  private readonly authBase = 'https://prelive-oauth2.quran.foundation/oauth2/token';
  private readonly apiBase = 'https://apis-prelive.quran.foundation/content/api/v4';
  private readonly cdnBase = 'https://verses.quran.foundation';
  private readonly CACHE_TTL = 3600 * 24; // 24 Hours cache

  constructor(
    private readonly httpService: HttpService,
    private readonly redisService: RedisService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * Obtains or retrieves cached Server-to-Server content access token
   */
  private async getAuthHeaders(): Promise<Record<string, string>> {
    const clientId = this.configService.get<string>('QURAN_CLIENT_ID');
    const clientSecret = this.configService.get<string>('QURAN_CLIENT_SECRET');
    
    if (!clientId || !clientSecret) {
      // Logically shouldn't happen if env is loaded, fall back to none or error.
      throw new HttpException('System misconfigured: Missing Quran Foundation Credentials', HttpStatus.INTERNAL_SERVER_ERROR);
    }

    const cacheKey = 'sys:quran:foundation_token';
    
    try {
      const cachedToken = await this.redisService.getClient().get(cacheKey);
      if (cachedToken) {
        return {
          'x-auth-token': cachedToken,
          'x-client-id': clientId,
        };
      }
    } catch (e) {}

    // Fetch new via Basic Auth Client Credentials grant
    try {
      const basicAuth = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
      const response = await firstValueFrom(
        this.httpService.post(
          this.authBase,
          'grant_type=client_credentials&scope=content',
          {
            headers: {
              'Authorization': `Basic ${basicAuth}`,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
          }
        )
      );

      const token = response.data.access_token;
      const expiresIn = response.data.expires_in || 3500;

      // Store in redis slightly less than expiry
      await this.redisService.getClient().set(cacheKey, token, 'EX', expiresIn - 60);

      return {
        'x-auth-token': token,
        'x-client-id': clientId,
      };
    } catch (err) {
      throw new HttpException('Quran.Foundation Authentication Failure', HttpStatus.BAD_GATEWAY);
    }
  }

  /**
   * Fetches real-time Audio URL for a specific Ayah using official API
   */
  async getVerseAudioUrl(verseKey: string, reciterId: number = 7): Promise<string | null> {
    const cacheKey = `audio:${verseKey}:reciter:${reciterId}`;
    
    try {
      const cached = await this.redisService.getClient().get(cacheKey);
      if (cached) return cached;
    } catch (e) {}

    try {
      const headers = await this.getAuthHeaders();
      const url = `${this.apiBase}/recitations/${reciterId}/by_ayah/${verseKey}`;
      
      const response = await firstValueFrom(
        this.httpService.get(url, { headers })
      );

      const audioPath = response.data?.audio_files?.[0]?.url;
      
      if (!audioPath) return null;
      
      // Construct full delivery URL using official CDN Base
      // Ensure we don't double slash if path starts with one
      const fullUrl = `${this.cdnBase}/${audioPath.startsWith('/') ? audioPath.substring(1) : audioPath}`;

      // Cache indefinitely practically (1 week)
      await this.redisService.getClient().set(cacheKey, fullUrl, 'EX', 604800);
      
      return fullUrl;
    } catch (e) {
      // Fallback gracefully to null so API doesn't crash if audio resolver hiccups
      return null;
    }
  }

  async getVerseByKey(verseKey: string, translationId: number = 85): Promise<any> {
    const cacheKey = `verse:${verseKey}:tr:${translationId}`;
    
    try {
      const cached = await this.redisService.getClient().get(cacheKey);
      if (cached) return JSON.parse(cached);
    } catch (e) {}

    try {
      const headers = await this.getAuthHeaders();
      const url = `${this.apiBase}/verses/by_key/${verseKey}?translations=${translationId}&fields=text_uthmani`;
      
      const response = await firstValueFrom(
        this.httpService.get(url, { headers })
      );
      const verseData = response.data?.verse;

      if (!verseData) {
        throw new HttpException(`Verse ${verseKey} not found`, HttpStatus.NOT_FOUND);
      }

      // Fetch audio link concurrently
      const audioUrl = await this.getVerseAudioUrl(verseData.verse_key);

      const result = {
        id: verseData.id,
        verseKey: verseData.verse_key,
        textUthmani: verseData.text_uthmani,
        chapterNumber: parseInt(verseData.verse_key.split(':')[0]),
        verseNumber: verseData.verse_number,
        pageNumber: verseData.page_number,
        juzNumber: verseData.juz_number,
        translation: verseData.translations?.[0]?.text || null,
        audioUrl: audioUrl,
      };

      this.redisService.getClient().set(cacheKey, JSON.stringify(result), 'EX', this.CACHE_TTL).catch(() => {});
      return result;

    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new HttpException('Failed to connect to official Quran Foundation APIs', HttpStatus.BAD_GATEWAY);
    }
  }

  async getRandomVerse(translationId: number = 85): Promise<any> {
    try {
      const headers = await this.getAuthHeaders();
      const url = `${this.apiBase}/verses/random?translations=${translationId}&fields=text_uthmani`;
      
      const response = await firstValueFrom(
        this.httpService.get(url, { headers })
      );
      const verseData = response.data?.verse;

      if (!verseData) throw new HttpException(`Random verse failure`, HttpStatus.NOT_FOUND);

      // Fetch audio link
      const audioUrl = await this.getVerseAudioUrl(verseData.verse_key);

      return {
        id: verseData.id,
        verseKey: verseData.verse_key,
        textUthmani: verseData.text_uthmani,
        chapterNumber: parseInt(verseData.verse_key.split(':')[0]),
        verseNumber: verseData.verse_number,
        pageNumber: verseData.page_number,
        juzNumber: verseData.juz_number,
        translation: verseData.translations?.[0]?.text || null,
        audioUrl: audioUrl,
      };
    } catch (error) {
      if (error instanceof HttpException) throw error;
      throw new HttpException('Failed to fetch random data from Quran Foundation', HttpStatus.BAD_GATEWAY);
    }
  }
}
