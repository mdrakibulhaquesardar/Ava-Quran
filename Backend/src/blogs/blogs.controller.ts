import { Controller, Get, Post, Body, Param, Query, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { BlogsService } from './blogs.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Blogs')
@Controller('blogs')
export class BlogsController {
  constructor(private readonly blogsService: BlogsService) {}

  @ApiOperation({ summary: 'Get a paginated list of public community blogs' })
  @Get()
  async getBlogs(
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
  ) {
    return this.blogsService.getPublicBlogs(
      parseInt(page, 10),
      parseInt(limit, 10),
    );
  }

  @ApiOperation({ summary: 'Get details for a single blog article' })
  @Get(':id')
  async getBlogDetails(@Param('id') id: string) {
    return this.blogsService.getBlogDetails(id);
  }

  @ApiOperation({ summary: 'Create and publish a new community blog' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post()
  async createBlog(
    @Req() req: any,
    @Body() body: { title: string; content: string },
  ) {
    return this.blogsService.createBlog(
      req.user.userId,
      body.title,
      body.content,
    );
  }
}
