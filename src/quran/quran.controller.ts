import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { QuranService } from './quran.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Quran Data')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('quran')
export class QuranController {
  constructor(private readonly quranService: QuranService) {}

  @ApiOperation({ summary: 'Fetch a single authenticated ayah content and audio' })
  @Get('ayah/:key')
  async getAyah(@Param('key') key: string) {
    return this.quranService.getVerseByKey(key);
  }

  @ApiOperation({ summary: 'Fetch list of all Surahs/Chapters' })
  @ApiQuery({ name: 'language', required: false, description: 'Translated name language e.g. "en"' })
  @Get('chapters')
  async getChapters(@Query() query: any) {
    return this.quranService.proxyGet('chapters', query);
  }

  @ApiOperation({ summary: 'Fetch a specific Surah info' })
  @Get('chapters/:id')
  async getChapterById(@Param('id') id: string, @Query() query: any) {
    return this.quranService.proxyGet(`chapters/${id}`, query);
  }

  @ApiOperation({ summary: 'Fetch Verses by Chapter' })
  @ApiQuery({ name: 'page', required: false })
  @Get('chapters/:id/verses')
  async getChapterVerses(@Param('id') id: string, @Query() query: any) {
    return this.quranService.proxyGet(`verses/by_chapter/${id}`, {
      translations: 85,
      fields: 'text_uthmani',
      ...query
    });
  }

  @ApiOperation({ summary: 'Run official server-side keyword search' })
  @ApiQuery({ name: 'q', required: true, description: 'Query term' })
  @ApiQuery({ name: 'page', required: false })
  @Get('search')
  async search(@Query() query: any) {
    return this.quranService.proxyGet('search', query);
  }
}
