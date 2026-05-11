import { Module } from '@nestjs/common';
import { FeedService } from './feed.service';
import { FeedController } from './feed.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { QuranModule } from '../quran/quran.module';

@Module({
  imports: [PrismaModule, QuranModule],
  controllers: [FeedController],
  providers: [FeedService],
})
export class FeedModule {}
