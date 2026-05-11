import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean } from 'class-validator';

export class UpdateOnboardingDto {
  @ApiProperty({ example: true })
  @IsBoolean()
  onboardingComplete: boolean;
}
