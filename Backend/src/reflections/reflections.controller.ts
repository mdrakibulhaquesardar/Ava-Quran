import { Controller, Get, Post, Delete, Param, Body, Query, UseGuards, Req, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ReflectionsService } from './reflections.service';
import { CreateReflectionDto } from './dto/create-reflection.dto';

@ApiTags('Reflections')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('reflections')
export class ReflectionsController {
  constructor(private readonly reflectionsService: ReflectionsService) {}

  @ApiOperation({ summary: 'Create a new personal reflection log tied to an ayah' })
  @Post()
  async create(@Req() req: any, @Body() dto: CreateReflectionDto) {
    return this.reflectionsService.create(req.user.userId, dto);
  }

  @ApiOperation({ summary: 'List own reflection timeline' })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  @ApiQuery({ name: 'ayahKey', required: false, description: 'Filter by specific ayah (e.g. 2:255)' })
  @Get()
  async findAll(
    @Req() req: any,
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '20',
    @Query('ayahKey') ayahKey?: string,
  ) {
    return this.reflectionsService.findAll(
      req.user.userId,
      parseInt(page, 10),
      parseInt(limit, 10),
      ayahKey
    );
  }

  @ApiOperation({ summary: 'Delete a specific entry' })
  @HttpCode(HttpStatus.NO_CONTENT)
  @Delete(':id')
  async remove(@Req() req: any, @Param('id') id: string) {
    await this.reflectionsService.remove(req.user.userId, id);
  }
}
