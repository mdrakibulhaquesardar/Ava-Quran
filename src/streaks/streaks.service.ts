import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class StreaksService {
  constructor(private readonly prisma: PrismaService) {}

  async getMyStreak(userId: string) {
    let streak = await this.prisma.streak.findUnique({
      where: { userId },
    });

    // Auto-provision streak card if initialized
    if (!streak) {
      streak = await this.prisma.streak.create({
        data: { userId },
      });
    }

    // Verify if the current streak is broken based on staleness
    const isBroken = this.isStreakExpired(streak.lastActiveDate);
    
    if (isBroken && streak.currentStreak > 0) {
      // Soft reset if user views it after a broken period
      return this.prisma.streak.update({
        where: { userId },
        data: { currentStreak: 0 }
      });
    }

    return streak;
  }

  async updateStreak(userId: string) {
    const existing = await this.getMyStreak(userId);
    const now = new Date();
    const lastActive = existing.lastActiveDate;

    // Case 1: Brand new user never tapped
    if (!lastActive) {
      return this.prisma.streak.update({
        where: { userId },
        data: {
          currentStreak: 1,
          longestStreak: Math.max(1, existing.longestStreak),
          lastActiveDate: now,
        },
      });
    }

    const diffDays = this.getDiffInDays(lastActive, now);

    // Case 2: Already tapped today - idempotent, do nothing!
    if (diffDays === 0) {
      return existing;
    }

    // Case 3: Perfect streak extension (exactly 1 day later)
    if (diffDays === 1) {
      const nextCount = existing.currentStreak + 1;
      return this.prisma.streak.update({
        where: { userId },
        data: {
          currentStreak: nextCount,
          longestStreak: Math.max(nextCount, existing.longestStreak),
          lastActiveDate: now,
        },
      });
    }

    // Case 4: Broken streak (skipped 2+ days)
    return this.prisma.streak.update({
      where: { userId },
      data: {
        currentStreak: 1,
        longestStreak: Math.max(1, existing.longestStreak),
        lastActiveDate: now,
      },
    });
  }

  private getDiffInDays(d1: Date, d2: Date): number {
    // Standardized to ISO date strings to cancel out microsecond drift
    const start = new Date(d1.toISOString().split('T')[0]);
    const end = new Date(d2.toISOString().split('T')[0]);
    const msPerDay = 1000 * 60 * 60 * 24;
    return Math.floor((end.getTime() - start.getTime()) / msPerDay);
  }

  private isStreakExpired(lastActive: Date | null): boolean {
    if (!lastActive) return false;
    const now = new Date();
    return this.getDiffInDays(lastActive, now) > 1;
  }
}
