import { Controller, Get, Post, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { StreaksService } from './streaks.service';

@ApiTags('Streaks')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('streaks')
export class StreaksController {
  constructor(private readonly streaksService: StreaksService) {}

  @ApiOperation({ summary: 'Get users current and historic daily streak stats' })
  @Get('me')
  async getStreak(@Req() req: any) {
    return this.streaksService.getMyStreak(req.user.userId);
  }

  @ApiOperation({ summary: 'Increment / Update daily activity (Idempotent)' })
  @Post('update')
  async updateStreak(@Req() req: any) {
    return this.streaksService.updateStreak(req.user.userId);
  }
}
