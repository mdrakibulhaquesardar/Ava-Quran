import { Controller, Get, Post, Delete, Param, Body, UseGuards, Req, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CollectionsService } from './collections.service';
import { CreateCollectionDto } from './dto/create-collection.dto';
import { AddAyahDto } from './dto/add-ayah.dto';

@ApiTags('Collections')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('collections')
export class CollectionsController {
  constructor(private readonly collectionsService: CollectionsService) {}

  @ApiOperation({ summary: 'Create a personal themed collection folder' })
  @Post()
  async create(@Req() req: any, @Body() dto: CreateCollectionDto) {
    return this.collectionsService.createCollection(req.user.userId, dto);
  }

  @ApiOperation({ summary: 'List user folders including aggregate counts' })
  @Get()
  async findAll(@Req() req: any) {
    return this.collectionsService.listCollections(req.user.userId);
  }

  @ApiOperation({ summary: 'Add a specific Ayah to a folder' })
  @Post(':id/ayahs')
  async addAyah(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: AddAyahDto
  ) {
    return this.collectionsService.addAyah(req.user.userId, id, dto);
  }

  @ApiOperation({ summary: 'Untag/Remove Ayah from a folder' })
  @HttpCode(HttpStatus.NO_CONTENT)
  @Delete(':id/ayahs/:ayahKey')
  async removeAyah(
    @Req() req: any,
    @Param('id') id: string,
    @Param('ayahKey') ayahKey: string
  ) {
    await this.collectionsService.removeAyah(req.user.userId, id, ayahKey);
  }
}
