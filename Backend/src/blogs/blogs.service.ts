import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class BlogsService {
  constructor(private readonly prisma: PrismaService) {}

  async createBlog(userId: string, title: string, content: string) {
    // 1. Content Preview: trim to first 150 chars with ellipses
    const cleanText = content.replace(/<[^>]*>/g, '');
    const preview = cleanText.length > 150 ? cleanText.substring(0, 150) + '...' : cleanText;

    // 2. Auto Read Time: approx 200 words/minute
    const words = content.split(/\s+/).filter(w => w.length > 0).length;
    const readTime = Math.max(1, Math.ceil(words / 200));

    // 3. Auto Thumbnail based on Content Sentiment/Keywords
    const theme = this.getThemeFromContent(title, content);
    const thumbnailUrl = this.getThumbnailUrlForTheme(theme);

    // 4. Save to db
    return this.prisma.blog.create({
      data: {
        userId,
        title,
        content,
        contentPreview: preview,
        readTime,
        thumbnailUrl,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            username: true,
            avatar: true,
          },
        },
      },
    });
  }

  async getPublicBlogs(page: number = 1, limit: number = 10) {
    const skip = (page - 1) * limit;

    const blogs = await this.prisma.blog.findMany({
      orderBy: {
        createdAt: 'desc',
      },
      skip,
      take: limit,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            username: true,
            avatar: true,
          },
        },
      },
    });

    return {
      items: blogs,
      hasMore: blogs.length === limit,
    };
  }

  async getBlogDetails(blogId: string) {
    const blog = await this.prisma.blog.findUnique({
      where: { id: blogId },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            username: true,
            avatar: true,
          },
        },
      },
    });

    if (!blog) {
      throw new NotFoundException('Blog article not found');
    }

    return blog;
  }

  // Content Parser to determine appropriate spiritual thumbnails
  private getThemeFromContent(title: string, content: string): string {
    const text = (title + ' ' + content).toLowerCase();
    if (text.includes('prayer') || text.includes('salah') || text.includes('dua') || text.includes('mosque') || text.includes('masjid') || text.includes('prostrat')) {
      return 'prayer';
    }
    if (text.includes('peace') || text.includes('calm') || text.includes('tranquil') || text.includes('heart') || text.includes('rest')) {
      return 'peace';
    }
    if (text.includes('gratitude') || text.includes('shukr') || text.includes('happy') || text.includes('blessing') || text.includes('thank')) {
      return 'gratitude';
    }
    if (text.includes('sad') || text.includes('pain') || text.includes('cry') || text.includes('hard') || text.includes('trial') || text.includes('difficulty')) {
      return 'sadness';
    }
    if (text.includes('hope') || text.includes('future') || text.includes('light') || text.includes('guide') || text.includes('tomorrow')) {
      return 'hope';
    }
    return 'quran';
  }

  private getThumbnailUrlForTheme(theme: string): string {
    const mappedImages: Record<string, string> = {
      prayer: 'https://images.unsplash.com/photo-1564507592933-d6e57377af86?auto=format&fit=crop&w=800&q=80', // Mosque arches
      peace: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80', // Calm mountain sunset
      gratitude: 'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=800&q=80', // Sunny nature trail
      sadness: 'https://images.unsplash.com/photo-1437382944881-45a9f73d025b?auto=format&fit=crop&w=800&q=80', // Rainy evening city lights
      hope: 'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?auto=format&fit=crop&w=800&q=80', // Radiant blue sky
      quran: 'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?auto=format&fit=crop&w=800&q=80', // Quran pages reading
    };
    return mappedImages[theme] || mappedImages['quran'];
  }
}
