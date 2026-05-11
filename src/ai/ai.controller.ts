import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { AiService } from './ai.service';
import { AiRequestDto } from './dto/ai-request.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('ai')
@UseGuards(JwtAuthGuard)
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('insight')
  async getInsight(@Body() dto: AiRequestDto) {
    return this.aiService.getInsight(dto.ayahKey);
  }

  @Post('emotion-tag')
  async getEmotionTags(@Body() dto: AiRequestDto) {
    return this.aiService.getEmotionTags(dto.ayahKey);
  }
}
