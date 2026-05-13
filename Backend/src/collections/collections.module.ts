import { Module } from '@nestjs/common';
import { CollectionsService } from './collections.service';
import { CollectionsController } from './collections.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { QuranSyncModule } from '../quran-sync/quran-sync.module';
import { FeedModule } from '../feed/feed.module';

@Module({
  imports: [PrismaModule, QuranSyncModule, FeedModule],
  providers: [CollectionsService],
  controllers: [CollectionsController]
})
export class CollectionsModule {}
