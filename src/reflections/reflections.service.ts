import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReflectionDto } from './dto/create-reflection.dto';
import { QuranSyncService } from '../quran-sync/quran-sync.service';

@Injectable()
export class ReflectionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly syncService: QuranSyncService,
  ) {}

  async create(userId: string, dto: CreateReflectionDto) {
    const res = await this.prisma.reflection.create({
      data: {
        userId,
        ayahKey: dto.ayahKey,
        content: dto.content,
        mood: dto.mood,
      },
    });

    // Trigger upstream sync (fire and forget, handles checks internally)
    this.syncService.syncReflectionToNotes(userId, dto.ayahKey, dto.content);

    return res;
  }

  async findAll(userId: string, page: number = 1, limit: number = 20, ayahKey?: string) {
    const skip = (page - 1) * limit;
    
    const where: any = { userId };
    if (ayahKey) {
      where.ayahKey = ayahKey;
    }

    const [data, total] = await Promise.all([
      this.prisma.reflection.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.reflection.count({ where })
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        hasMore: skip + data.length < total,
      }
    };
  }

  async remove(userId: string, reflectionId: string) {
    const reflection = await this.prisma.reflection.findUnique({
      where: { id: reflectionId },
    });

    if (!reflection) {
      throw new NotFoundException('Reflection entry not found');
    }

    if (reflection.userId !== userId) {
      throw new ForbiddenException('Cannot delete an entry that does not belong to you');
    }

    return this.prisma.reflection.delete({
      where: { id: reflectionId },
    });
  }
}
