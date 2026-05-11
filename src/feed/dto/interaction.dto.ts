import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsIn } from 'class-validator';

export class CreateInteractionDto {
  @ApiProperty({ example: '2:255', description: 'Ayah canonical key' })
  @IsString()
  ayahKey: string;

  @ApiProperty({
    example: 'viewed',
    enum: ['viewed', 'saved', 'reflected', 'shared', 'replayed', 'loved'],
    description: 'Type of user interaction logged for ranking heuristics',
  })
  @IsString()
  @IsIn(['viewed', 'saved', 'reflected', 'shared', 'replayed', 'loved'])
  interactionType: string;
}
