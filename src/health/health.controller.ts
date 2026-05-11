import { Controller, Get } from '@nestjs/common';
import {
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { HealthCheckResponseDto } from './dto/health-check.response.dto';

type CheckStatus = 'up' | 'down';

@ApiTags('Health')
@Controller('health')
export class HealthController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Liveness and dependency checks' })
  @ApiOkResponse({ type: HealthCheckResponseDto })
  async check(): Promise<{
    status: 'ok' | 'degraded';
    checks: { database: CheckStatus; redis: CheckStatus };
  }> {
    const checks = {
      database: (await this.checkDatabase()) ? 'up' : 'down',
      redis: (await this.checkRedis()) ? 'up' : 'down',
    } as const;

    const status =
      checks.database === 'up' && checks.redis === 'up' ? 'ok' : 'degraded';

    return { status, checks };
  }

  private async checkDatabase(): Promise<boolean> {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      return true;
    } catch {
      return false;
    }
  }

  private async checkRedis(): Promise<boolean> {
    try {
      const pong = await this.redis.ping();
      return pong === 'PONG';
    } catch {
      return false;
    }
  }
}
