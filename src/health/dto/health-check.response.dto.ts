import { ApiProperty } from '@nestjs/swagger';

export class HealthChecksDto {
  @ApiProperty({ enum: ['up', 'down'], description: 'PostgreSQL connectivity' })
  database!: 'up' | 'down';

  @ApiProperty({ enum: ['up', 'down'], description: 'Redis connectivity' })
  redis!: 'up' | 'down';
}

export class HealthCheckResponseDto {
  @ApiProperty({ enum: ['ok', 'degraded'] })
  status!: 'ok' | 'degraded';

  @ApiProperty({ type: HealthChecksDto })
  checks!: HealthChecksDto;
}
