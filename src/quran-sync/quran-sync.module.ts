import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from '../auth/auth.module';
import { QuranSyncService } from './quran-sync.service';

@Module({
  imports: [HttpModule, ConfigModule, AuthModule],
  providers: [QuranSyncService],
  exports: [QuranSyncService],
})
export class QuranSyncModule {}
