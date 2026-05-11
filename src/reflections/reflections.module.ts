import { Module } from '@nestjs/common';
import { ReflectionsService } from './reflections.service';
import { ReflectionsController } from './reflections.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { QuranSyncModule } from '../quran-sync/quran-sync.module';

@Module({
  imports: [PrismaModule, QuranSyncModule],
  providers: [ReflectionsService],
  controllers: [ReflectionsController],
})
export class ReflectionsModule {}
