import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { RedisService } from '../redis/redis.service';
import { QuranService } from '../quran/quran.service';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private readonly groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  private readonly modelName = 'llama-3.3-70b-versatile'; // Fast, highly capable Llama-3 on Groq

  constructor(
    private readonly httpService: HttpService,
    private readonly configService: ConfigService,
    private readonly redisService: RedisService,
    private readonly quranService: QuranService,
  ) {}

  private getApiKey(): string {
    const key = this.configService.get<string>('GROQ_API_KEY');
    if (!key) {
      throw new HttpException('AI System Unavailable: Missing credentials', HttpStatus.SERVICE_UNAVAILABLE);
    }
    return key;
  }

  async getInsight(ayahKey: string): Promise<{ insight: string }> {
    const cacheKey = `ai:insight:${ayahKey}`;
    
    // 1. Return cache immediately if present
    const cached = await this.redisService.getClient().get(cacheKey);
    if (cached) return { insight: cached };

    // 2. Get ground-truth verse text
    const verse = await this.quranService.getVerseByKey(ayahKey);
    const textToAnalyze = verse.translation || verse.textUthmani;

    // 3. Call Groq
    const prompt = `Provide a concise spiritual reflection (max 2-3 sentences) suitable for a daily reminder based on this Quranic verse: "${textToAnalyze}". The reflection should be motivational, gentle, and practical. Answer ONLY with the text of the reflection. No headers, no quotes.`;

    const resultText = await this.callGroqChat(prompt);
    
    // 4. Cache result permanently (verses don't change)
    await this.redisService.getClient().set(cacheKey, resultText);

    return { insight: resultText };
  }

  async getEmotionTags(ayahKey: string): Promise<{ tags: string[] }> {
    const cacheKey = `ai:tags:${ayahKey}`;
    
    const cached = await this.redisService.getClient().get(cacheKey);
    if (cached) return { tags: JSON.parse(cached) };

    const verse = await this.quranService.getVerseByKey(ayahKey);
    const textToAnalyze = verse.translation || verse.textUthmani;

    const prompt = `Analyze the emotional tone of this Quranic verse: "${textToAnalyze}". Return a strict JSON object containing a field "tags" which is an array of exactly 3 or 4 lowercase single-word strings mapping to positive emotions or spiritual states it promotes (e.g., {"tags": ["hope", "patience", "calm"]}).`;

    const rawResponse = await this.callGroqChat(prompt, true);
    
    try {
      const cleaned = rawResponse.replace(/```json/g, '').replace(/```/g, '').trim();
      const parsed = JSON.parse(cleaned);
      const tags = parsed.tags || parsed; // Fallback if it directly returns array despite instruction
      
      if (Array.isArray(tags)) {
        await this.redisService.getClient().set(cacheKey, JSON.stringify(tags));
        return { tags };
      }
    } catch (e) {
      this.logger.error(`Failed to parse LLM emotion JSON for ${ayahKey}:`, rawResponse);
    }

    // Fallback fallback if LLM glitches
    const fallback = ['reflection', 'guidance', 'peace'];
    return { tags: fallback };
  }

  private async callGroqChat(prompt: string, useJsonMode = false): Promise<string> {
    const apiKey = this.getApiKey();
    
    try {
      const response = await firstValueFrom(
        this.httpService.post(
          this.groqBaseUrl,
          {
            model: this.modelName,
            messages: [
              {
                role: 'system',
                content: useJsonMode 
                  ? 'You are a JSON response engine. Output valid JSON array structure only.' 
                  : 'You are a helpful Islamic companion assistant providing gentle insights.',
              },
              { role: 'user', content: prompt },
            ],
            temperature: 0.7,
            max_tokens: 150,
            response_format: useJsonMode ? { type: 'json_object' } : undefined,
          },
          {
            headers: {
              'Authorization': `Bearer ${apiKey}`,
              'Content-Type': 'application/json',
            },
          }
        )
      );

      const text = response.data?.choices?.[0]?.message?.content;
      if (!text) throw new Error('Empty response from Groq AI');
      return text.trim();

    } catch (error) {
      this.logger.error(`Groq API Error: ${error.message}`);
      if (error.response?.data) {
        this.logger.error(JSON.stringify(error.response.data));
      }
      throw new HttpException(
        'Failed to generate AI content. Please try again later.',
        HttpStatus.BAD_GATEWAY
      );
    }
  }
}
