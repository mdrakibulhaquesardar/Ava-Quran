import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { join } from 'node:path';
import { HealthModule } from './health/health.module';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { QuranModule } from './quran/quran.module';
import { FeedModule } from './feed/feed.module';
import { ReflectionsModule } from './reflections/reflections.module';
import { CollectionsModule } from './collections/collections.module';
import { StreaksModule } from './streaks/streaks.module';
import { QuranSyncModule } from './quran-sync/quran-sync.module';
import { AiModule } from './ai/ai.module';

const envDir = join(__dirname, '..');

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [join(envDir, '.env.local'), join(envDir, '.env')],
    }),
    PrismaModule,
    RedisModule,
    HealthModule,
    UsersModule,
    AuthModule,
    QuranModule,
    FeedModule,
    ReflectionsModule,
    CollectionsModule,
    StreaksModule,
    QuranSyncModule,
    AiModule,
  ],
})
export class AppModule {}
