import { Injectable, NotFoundException, ForbiddenException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCollectionDto } from './dto/create-collection.dto';
import { AddAyahDto } from './dto/add-ayah.dto';
import { QuranSyncService } from '../quran-sync/quran-sync.service';
import { FeedService } from '../feed/feed.service';
import { QuranService } from '../quran/quran.service';

@Injectable()
export class CollectionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly syncService: QuranSyncService,
    private readonly feedService: FeedService,
    private readonly quranService: QuranService,
  ) {}

  async createCollection(userId: string, dto: CreateCollectionDto) {
    const col = await this.prisma.collection.create({
      data: {
        userId,
        title: dto.title,
      },
    });
    return {
      id: col.id,
      title: col.title,
      savedCount: 0,
    };
  }

  async listCollections(userId: string) {
    const collections = await this.prisma.collection.findMany({
      where: { userId },
      include: {
        _count: {
          select: { ayahs: true }
        },
        ayahs: {
          orderBy: { createdAt: 'desc' },
          take: 1,
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    // Fast mapping combining dynamic aggregates and deterministic optimized image tokens
    return collections.map((col) => {
      const latestAyahKey = col.ayahs[0]?.ayahKey;
      let thumbnailUrl = 'https://images.unsplash.com/photo-1586767003402-8ade266deb64'; // Soft Quran landscape default
      
      if (latestAyahKey) {
        const seed = latestAyahKey.split(':').reduce((acc, v) => acc + parseInt(v, 10), 0);
        const pool = [
          'https://images.unsplash.com/photo-1590273089302-ebbc53986b6e',
          'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f',
          'https://images.unsplash.com/photo-1519817650390-64a93db51149',
          'https://images.unsplash.com/photo-1575645513913-c002ea3b2e01',
          'https://images.unsplash.com/photo-1542816417-0983c9c9ad53',
          'https://images.unsplash.com/photo-1580220810949-e7ddee6a4954',
        ];
        thumbnailUrl = pool[seed % pool.length];
      }

      return {
        id: col.id,
        title: col.title,
        savedCount: col._count.ayahs,
        thumbnailUrl: `${thumbnailUrl}?auto=format&fit=crop&w=800&q=80`,
        createdAt: col.createdAt,
      };
    });
  }

  async getCollectionAyahs(userId: string, collectionId: string, lang: string = 'en') {
    await this.verifyOwnership(userId, collectionId);

    const collectionAyahs = await this.prisma.collectionAyah.findMany({
      where: { collectionId },
      orderBy: { createdAt: 'desc' }
    });

    // Support i18n dynamically
    const translationId = lang.toLowerCase() === 'bn' ? 161 : 85;

    // High-speed parallel hydration utilizing proxies
    const hydrationPromises = collectionAyahs.map(async (cAyah) => {
      try {
        const content = await this.quranService.getVerseByKey(cAyah.ayahKey, translationId);
        const enriched = await this.feedService.enrichFeedItem(content, 'peaceful', cAyah.ayahKey, userId);
        return { ...enriched, isSaved: true };
      } catch (e) {
        return null;
      }
    });

    const items = (await Promise.all(hydrationPromises)).filter(Boolean);

    return {
      items,
    };
  }

  async addAyah(userId: string, collectionId: string, dto: AddAyahDto) {
    await this.verifyOwnership(userId, collectionId);

    try {
      const res = await this.prisma.collectionAyah.create({
        data: {
          collectionId,
          ayahKey: dto.ayahKey,
        }
      });

      // Silently queue upstream third-party backup
      this.syncService.syncCollectionAyahToBookmark(userId, dto.ayahKey).catch(() => {});

      return res;
    } catch (error) {
      if (error.code === 'P2002') {
        throw new ConflictException('This ayah is already present in the collection');
      }
      throw error;
    }
  }

  async removeAyah(userId: string, collectionId: string, ayahKey: string) {
    await this.verifyOwnership(userId, collectionId);

    const existing = await this.prisma.collectionAyah.findUnique({
      where: { collectionId_ayahKey: { collectionId, ayahKey } }
    });

    if (!existing) {
      throw new NotFoundException('Item not found in this collection');
    }

    return this.prisma.collectionAyah.delete({
      where: { collectionId_ayahKey: { collectionId, ayahKey } }
    });
  }

  private async verifyOwnership(userId: string, collectionId: string) {
    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException('Collection not found');
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException('Unauthorized access to this collection');
    }
    
    return collection;
  }
}
