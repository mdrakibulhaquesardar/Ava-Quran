import { Controller, Get, Post, Delete, Patch, Body, Query, Param, UseGuards, Req, NotFoundException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UpdatePreferencesDto } from './dto/update-preferences.dto';
import { UpdateOnboardingDto } from './dto/update-onboarding.dto';

@ApiTags('Users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @ApiOperation({ summary: 'Get current authenticated user profile + preferences' })
  @Get('me')
  async getMe(@Req() req: any) {
    const user = await this.usersService.findOneById(req.user.userId);
    if (!user) {
      throw new NotFoundException('User profile not found');
    }
    // strip credentials
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, quranAccessToken, quranRefreshToken, ...safeUser } = user;
    return safeUser;
  }

  @ApiOperation({ summary: 'Update user reading/language preferences' })
  @Patch('preferences')
  async updatePreferences(@Req() req: any, @Body() dto: UpdatePreferencesDto) {
    const updated = await this.usersService.updateUser(req.user.userId, {
      preferredLanguage: dto.preferredLanguage,
      favoriteReciter: dto.favoriteReciter,
      moodPreference: dto.moodPreference,
    });
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, quranAccessToken, quranRefreshToken, ...safeUser } = updated;
    return safeUser;
  }

  @ApiOperation({ summary: 'Mark onboarding setup steps complete' })
  @Patch('onboarding')
  async updateOnboarding(@Req() req: any, @Body() dto: UpdateOnboardingDto) {
    const updated = await this.usersService.updateUser(req.user.userId, {
      onboardingComplete: dto.onboardingComplete,
    });
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, quranAccessToken, quranRefreshToken, ...safeUser } = updated;
    return safeUser;
  }

  @ApiOperation({ summary: 'Get a paginated list of platform users to discover' })
  @Get('discover')
  async getDiscover(
    @Req() req: any,
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '20',
  ) {
    return this.usersService.getDiscoverUsers(
      req.user.userId,
      parseInt(page, 10),
      parseInt(limit, 10),
    );
  }

  @ApiOperation({ summary: 'Follow a specific community member' })
  @Post('follow')
  async followUser(@Req() req: any, @Body() body: { targetUserId: string }) {
    return this.usersService.followUser(req.user.userId, body.targetUserId);
  }

  @ApiOperation({ summary: 'Unfollow a community member' })
  @Delete('follow/:targetUserId')
  async unfollowUser(@Req() req: any, @Param('targetUserId') targetUserId: string) {
    return this.usersService.unfollowUser(req.user.userId, targetUserId);
  }
}
