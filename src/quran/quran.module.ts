import { Module, Global } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { QuranService } from './quran.service';
import { RedisModule } from '../redis/redis.module';

@Global()
@Module({
  imports: [HttpModule, RedisModule],
  providers: [QuranService],
  exports: [QuranService],
})
export class QuranModule {}
