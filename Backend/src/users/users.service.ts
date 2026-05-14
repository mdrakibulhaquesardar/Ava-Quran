import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { User, Prisma } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findOneByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async findOneByQuranId(quranId: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { quranId },
    });
  }

  async findOneById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { id },
      include: {
        streak: true,
      },
    }) as any;
  }

  async createUser(data: Prisma.UserCreateInput): Promise<User> {
    return this.prisma.user.create({
      data,
    });
  }

  async updateUser(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return this.prisma.user.update({
      where: { id },
      data,
    });
  }

  async getDiscoverUsers(userId: string, page: number = 1, limit: number = 20) {
    const users = await this.prisma.user.findMany({
      where: {
        id: { not: userId },
      },
      orderBy: {
        followersCount: 'desc',
      },
      skip: (page - 1) * limit,
      take: limit,
      include: {
        followers: {
          where: {
            followerId: userId,
          },
          select: {
            id: true,
          },
        },
      },
    });

    // 2. Map to standard DTO extracting safe non-credential fields
    const items = users.map((u) => {
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { passwordHash, quranAccessToken, quranRefreshToken, followers, ...safeUser } = u;
      return {
        ...safeUser,
        isFollowing: followers.length > 0,
      };
    });

    return {
      items,
      hasMore: items.length === limit,
    };
  }

  async followUser(followerId: string, followingId: string) {
    if (followerId === followingId) {
      throw new BadRequestException('Cannot follow oneself');
    }

    try {
      // Atomic graph edge commit paired with scalar increments
      await this.prisma.$transaction([
        this.prisma.userFollow.create({
          data: {
            followerId,
            followingId,
          },
        }),
        this.prisma.user.update({
          where: { id: followerId },
          data: { followingCount: { increment: 1 } },
        }),
        this.prisma.user.update({
          where: { id: followingId },
          data: { followersCount: { increment: 1 } },
        }),
      ]);
      return { success: true };
    } catch (e) {
      // Suppress collision errors on duplicate follow streams
      if (e.code === 'P2002') {
        return { success: true, message: 'Already followed' };
      }
      throw e;
    }
  }

  async unfollowUser(followerId: string, followingId: string) {
    try {
      // Verify follow edge actually exists before subtracting to prevent negative counter drifting
      const edge = await this.prisma.userFollow.findUnique({
        where: {
          followerId_followingId: {
            followerId,
            followingId,
          },
        },
      });
      
      if (!edge) return { success: true };

      await this.prisma.$transaction([
        this.prisma.userFollow.delete({
          where: {
            id: edge.id,
          },
        }),
        this.prisma.user.update({
          where: { id: followerId },
          data: { followingCount: { decrement: 1 } },
        }),
        this.prisma.user.update({
          where: { id: followingId },
          data: { followersCount: { decrement: 1 } },
        }),
      ]);
      return { success: true };
    } catch (e) {
      throw e;
    }
  }
}
