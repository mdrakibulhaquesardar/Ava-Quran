import { Module, Global } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { QuranService } from './quran.service';
import { QuranController } from './quran.controller';
import { RedisModule } from '../redis/redis.module';

@Global()
@Module({
  imports: [HttpModule, RedisModule],
  controllers: [QuranController],
  providers: [QuranService],
  exports: [QuranService],
})
export class QuranModule {}
