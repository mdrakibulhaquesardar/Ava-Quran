import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { QuranService } from '../quran/quran.service';
import { CreateInteractionDto } from './dto/interaction.dto';

@Injectable()
export class FeedService {
  // Curated MVP Map linking moods to canonical ayah keys
  private readonly moodMap: Record<string, string[]> = {
    peaceful: ['2:255', '13:28', '55:60', '89:27', '89:28', '89:29', '89:30'],
    anxious: ['2:286', '94:5', '94:6', '2:152', '3:173', '8:30'],
    sad: ['12:86', '39:53', '93:3', '93:4', '93:5', '2:216'],
    grateful: ['14:7', '16:18', '2:152', '27:40', '55:13'],
    searching: ['29:69', '20:25', '2:269', '35:29'],
    inspired: ['2:25', '3:133', '3:191', '25:63'],
  };

  // Fallback generic carousel when no mood is selected or found
  private readonly defaultKeys = ['1:1', '2:255', '39:53', '94:5', '14:7'];

  constructor(
    private readonly prisma: PrismaService,
    private readonly quranService: QuranService,
  ) {}

  async getFeed(userId: string, inputMood: string, page: number = 1, limit: number = 10) {
    const mood = inputMood?.toLowerCase() || 'peaceful';
    
    // 1. Get target keys for this specific mood
    const sourceKeys = this.moodMap[mood] || this.defaultKeys;

    // 2. Optional optimization: Check user's already viewed history to demote them?
    // Skipping complex dedupe logic for MVP to ensure consistent content availability.
    
    // 3. Handle Pagination Logic on our small array
    const startIndex = (page - 1) * limit;
    const pageKeys = sourceKeys.slice(startIndex, startIndex + limit);

    // 4. Resolve and parallel hydrate actual content via proxy
    const hydrationPromises = pageKeys.map(async (key) => {
      try {
        const content = await this.quranService.getVerseByKey(key);
        return {
          ...content,
          moodTag: mood,
          // Mock AI Insight component described in PRD
          aiInsight: this.generateMockInsight(key, mood),
        };
      } catch (e) {
        return null; // Drop errored entries gracefully
      }
    });

    const results = (await Promise.all(hydrationPromises)).filter(Boolean);

    // 5. SEAMLESS BACKFILL: If list is shorter than limit (exhausted curated content),
    // Inject truly random verses from Quran.Foundation so feed NEVER ends.
    const remaining = limit - results.length;
    if (remaining > 0) {
      const fillPromises = Array.from({ length: remaining }).map(async () => {
        try {
          const content = await this.quranService.getRandomVerse();
          return {
            ...content,
            moodTag: 'discovery',
            aiInsight: this.generateMockInsight(content.verseKey, 'discovery'),
          };
        } catch (e) {
          return null;
        }
      });
      const fillResults = (await Promise.all(fillPromises)).filter(Boolean);
      results.push(...fillResults as any[]);
    }

    return {
      data: results,
      meta: {
        total: results.length < limit ? results.length : Math.max(sourceKeys.length, page * limit), 
        page,
        limit,
        hasMore: true, // Feed never actually ends due to random injector
      },
    };
  }

  async getRecommended(userId: string) {
    // Returns fixed high quality highlights
    return this.getFeed(userId, 'peaceful', 1, 5);
  }

  async trackInteraction(userId: string, dto: CreateInteractionDto) {
    return this.prisma.feedHistory.create({
      data: {
        userId,
        ayahKey: dto.ayahKey,
        interactionType: dto.interactionType,
      },
    });
  }

  private generateMockInsight(key: string, mood: string): string {
    const genericMessages = [
      "Take a moment to let these words sink into your heart.",
      "A reminder meant for moments exactly like this.",
      "Notice the tranquility found within this specific sequence.",
      "Reflect on how this directly connects to your current mood state.",
    ];
    // Simple deterministic picker using the first part of hash
    const index = key.length % genericMessages.length;
    return genericMessages[index];
  }
}
