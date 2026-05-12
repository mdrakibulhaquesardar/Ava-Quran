import { Controller, Post, Body, Get, UseGuards, Req, Res, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBody, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import type { Response } from 'express';
import { AuthService } from './auth.service';
import { LocalAuthGuard } from './guards/local-auth.guard';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @ApiOperation({ summary: 'Register a new user with email and password' })
  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @ApiOperation({ summary: 'Log in with email and password' })
  @UseGuards(LocalAuthGuard)
  @ApiBody({ type: LoginDto })
  @Post('login')
  async login(@Req() req: any) {
    // LocalAuthGuard attaches 'user' object from LocalStrategy validate
    return this.authService.login(req.user);
  }

  @ApiOperation({ summary: 'Refresh an expired access token' })
  @Post('refresh')
  async refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshAccessToken(dto.refreshToken);
  }

  @ApiOperation({ summary: 'Log out and invalidate session refresh tokens' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('logout')
  async logout(@Req() req: any) {
    await this.authService.logout(req.user.userId);
    return { success: true, message: 'Logged out successfully' };
  }

  @ApiOperation({ summary: 'Redirect user to Quran.Foundation login' })
  @ApiQuery({ name: 'redirectUri', required: false, description: 'Custom frontend redirect URL after successful OAuth' })
  @Get('quran/login')
  quranLogin(@Req() req: any, @Query('redirectUri') queryRedirect: string, @Res() res: Response) {
    const protocol = req.protocol;
    const host = req.get('Host');
    const fallback = `${protocol}://${host}/auth/quran/callback`;
    
    const url = this.authService.getQuranOAuthUrl(queryRedirect || fallback);
    res.redirect(url);
  }

  @ApiOperation({ summary: 'Link currently logged in profile to Quran.Foundation' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiQuery({ name: 'redirectUri', required: false })
  @Get('quran/link')
  quranLink(@Req() req: any, @Query('redirectUri') queryRedirect: string, @Res() res: Response) {
    const userId = req.user.userId;
    const protocol = req.protocol;
    const host = req.get('Host');
    const fallback = `${protocol}://${host}/auth/quran/callback`;

    // Pass userId in state so callback knows to link to THIS user instead of new creation
    const url = this.authService.getQuranOAuthUrl(queryRedirect || fallback, userId);
    res.redirect(url);
  }

  @ApiOperation({ summary: 'Handle Quran.Foundation OAuth Callback' })
  @ApiQuery({ name: 'code', required: true })
  @ApiQuery({ name: 'state', required: false, description: 'UserId used during linking process' })
  @Get('quran/callback')
  async quranCallback(
    @Query('code') code: string,
    @Query('state') state: string,
    @Req() req: any,
  ) {
    const redirectUri = `${req.protocol}://${req.get('host')}${req.path}`;
    return this.authService.handleQuranCallback(code, redirectUri, state);
  }

  @ApiOperation({ summary: 'Get current logged in user profile (Testing JWT)' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Req() req: any) {
    return req.user;
  }
}
