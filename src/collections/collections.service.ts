import { Injectable, NotFoundException, ForbiddenException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCollectionDto } from './dto/create-collection.dto';
import { AddAyahDto } from './dto/add-ayah.dto';
import { QuranSyncService } from '../quran-sync/quran-sync.service';

@Injectable()
export class CollectionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly syncService: QuranSyncService,
  ) {}

  async createCollection(userId: string, dto: CreateCollectionDto) {
    return this.prisma.collection.create({
      data: {
        userId,
        title: dto.title,
      },
    });
  }

  async listCollections(userId: string) {
    // Automatically pull counts or minimal ayah relationship payload
    return this.prisma.collection.findMany({
      where: { userId },
      include: {
        _count: {
          select: { ayahs: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });
  }

  async addAyah(userId: string, collectionId: string, dto: AddAyahDto) {
    // 1. Verify collection ownership
    await this.verifyOwnership(userId, collectionId);

    // 2. Upsert relationship preventing duplicates cleanly
    try {
      const res = await this.prisma.collectionAyah.create({
        data: {
          collectionId,
          ayahKey: dto.ayahKey,
        }
      });

      // Trigger upstream cloud sync
      this.syncService.syncCollectionAyahToBookmark(userId, dto.ayahKey);

      return res;
    } catch (error) {
      // Unique constraint violation code for Prisma is P2002
      if (error.code === 'P2002') {
        throw new ConflictException('This ayah is already present in the collection');
      }
      throw error;
    }
  }

  async removeAyah(userId: string, collectionId: string, ayahKey: string) {
    await this.verifyOwnership(userId, collectionId);

    // Perform soft look-up cleanup delete
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
