import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateReflectionDto {
  @ApiProperty({ example: '2:255', description: 'Target ayah key code' })
  @IsString()
  @IsNotEmpty()
  ayahKey: string;

  @ApiProperty({ example: 'I felt deeply calm after reading this.', description: 'Journal content' })
  @IsString()
  @IsNotEmpty()
  content: string;

  @ApiProperty({ example: 'peaceful', required: false, description: 'Optional mood association' })
  @IsString()
  @IsOptional()
  mood?: string;
}
