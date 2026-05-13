import { Controller, Get, Post, Body, Query, UseGuards, Req, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { FeedService } from './feed.service';
import { CreateInteractionDto } from './dto/interaction.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Feed')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('feed')
export class FeedController {
  constructor(private readonly feedService: FeedService) {}

  @ApiOperation({ summary: 'Get paginated, personalized vertical feed' })
  @ApiQuery({ name: 'mood', required: false, description: 'Target mood tag (e.g. anxious, peaceful)' })
  @ApiQuery({ name: 'lang', required: false, description: 'ISO Language code e.g. "en", "bn" for translation' })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  @Get()
  async getFeed(
    @Req() req: any,
    @Query('mood') mood: string = '',
    @Query('lang') lang: string = 'en',
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
  ) {
    return this.feedService.getFeed(
      req.user.userId, 
      mood, 
      lang,
      parseInt(page, 10), 
      parseInt(limit, 10)
    );
  }

  @ApiOperation({ summary: 'Fetch highly recommended standard highlights' })
  @ApiQuery({ name: 'lang', required: false, description: 'ISO Language code e.g. "en", "bn"' })
  @Get('recommended')
  async getRecommended(
    @Req() req: any,
    @Query('lang') lang: string = 'en',
  ) {
    return this.feedService.getRecommended(req.user.userId, lang);
  }

  @ApiOperation({ summary: 'Log analytic signals from frontend (saves, swipes, plays)' })
  @Post('interactions')
  async logInteraction(@Req() req: any, @Body() dto: CreateInteractionDto) {
    return this.feedService.trackInteraction(req.user.userId, dto);
  }

  @ApiOperation({ summary: 'Get top reels sorted by love engagement DESC' })
  @ApiQuery({ name: 'limit', required: false })
  @ApiQuery({ name: 'lang', required: false })
  @Get('most-loved')
  async getMostLoved(
    @Req() req: any,
    @Query('limit') limit: string = '10',
    @Query('lang') lang: string = 'en',
  ) {
    return this.feedService.getMostLoved(
      req.user.userId,
      lang,
      parseInt(limit, 10)
    );
  }
}
