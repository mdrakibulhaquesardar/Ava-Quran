import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from './dto/register.dto';
import { User } from '@prisma/client';
import { firstValueFrom } from 'rxjs';
import { RedisService } from '../redis/redis.service';
import { randomUUID } from 'crypto';

@Injectable()
export class AuthService {
  private readonly REFRESH_TTL = 7 * 24 * 60 * 60; // 7 days in seconds

  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
    private readonly redisService: RedisService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.usersService.findOneByEmail(dto.email);
    if (existing) {
      throw new BadRequestException('Email already in use');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(dto.password, salt);

    const user = await this.usersService.createUser({
      email: dto.email,
      passwordHash,
      name: dto.name,
    });

    return await this.generateToken(user);
  }

  async validateUser(email: string, pass: string): Promise<any> {
    const user = await this.usersService.findOneByEmail(email);
    if (!user || !user.passwordHash) {
      return null;
    }
    const isMatch = await bcrypt.compare(pass, user.passwordHash);
    if (isMatch) {
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { passwordHash, ...result } = user;
      return result;
    }
    return null;
  }

  async login(user: any) {
    return await this.generateToken(user);
  }

  async generateToken(user: Partial<User>) {
    if (!user.id) throw new UnauthorizedException('Authentication failure: Incomplete payload');
    const payload = { sub: user.id, email: user.email };
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = randomUUID();

    // Map the token to the User ID for rapid lookups
    const tokenKey = `auth:rt:${refreshToken}`;
    await this.redisService.getClient().set(tokenKey, user.id, 'EX', this.REFRESH_TTL);
    
    // Optionally link user to token to support single-session logout (delete current token index)
    const userKey = `auth:usr_rt:${user.id}`;
    await this.redisService.getClient().set(userKey, refreshToken, 'EX', this.REFRESH_TTL);

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    };
  }

  async logout(userId: string): Promise<void> {
    const userKey = `auth:usr_rt:${userId}`;
    const currentToken = await this.redisService.getClient().get(userKey);
    if (currentToken) {
      await this.redisService.getClient().del(`auth:rt:${currentToken}`);
    }
    await this.redisService.getClient().del(userKey);
  }

  async refreshAccessToken(token: string): Promise<{ access_token: string; refresh_token: string }> {
    const tokenKey = `auth:rt:${token}`;
    const userId = await this.redisService.getClient().get(tokenKey);

    if (!userId) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    // Optional: Rotates token immediately for enhanced security
    await this.redisService.getClient().del(tokenKey);
    
    const user = await this.usersService.findOneById(userId);
    if (!user) throw new UnauthorizedException('User not found');

    // Generate shiny new token pair!
    const pair = await this.generateToken(user);
    return {
      access_token: pair.access_token,
      refresh_token: pair.refresh_token,
    };
  }


  getQuranOAuthUrl(redirectUri: string, state?: string) {
    const baseUrl = this.configService.get<string>('Quran_END_POINT') || 'https://prelive-oauth2.quran.foundation';
    const clientId = this.configService.get<string>('QURAN_CLIENT_ID');
    const query: Record<string, string> = {
      client_id: clientId || '',
      redirect_uri: redirectUri,
      response_type: 'code',
      scope: 'openid offline_access',
    };
    if (state) {
      query.state = state;
    }
    const q = new URLSearchParams(query);
    return `${baseUrl}/oauth2/auth?${q.toString()}`;
  }

  async handleQuranCallback(code: string, redirectUri: string, state?: string) {
    const baseUrl = this.configService.get<string>('Quran_END_POINT') || 'https://prelive-oauth2.quran.foundation';
    const clientId = this.configService.get<string>('QURAN_CLIENT_ID');
    const clientSecret = this.configService.get<string>('QURAN_CLIENT_SECRET');

    try {
      // 1. Exchange code for token
      const tokenRes = await firstValueFrom(
        this.httpService.post(`${baseUrl}/oauth2/token`, {
          grant_type: 'authorization_code',
          code,
          redirect_uri: redirectUri,
          client_id: clientId,
          client_secret: clientSecret,
        }),
      );

      const { access_token, refresh_token, expires_in } = tokenRes.data;
      const expiresAt = expires_in ? new Date(Date.now() + expires_in * 1000) : null;

      // 2. Get user info
      const userRes = await firstValueFrom(
        this.httpService.get(`${baseUrl}/userinfo`, {
          headers: { Authorization: `Bearer ${access_token}` },
        }),
      );

      const quranProfile = userRes.data;
      const quranId = String(quranProfile.sub || quranProfile.id);
      const email = quranProfile.email;

      if (!quranId) {
        throw new UnauthorizedException('Invalid profile returned from provider.');
      }

      // Build update payload for tokens
      const tokenData = {
        quranAccessToken: access_token,
        quranRefreshToken: refresh_token,
        quranTokenExpiresAt: expiresAt,
      };

      // 3. Check linking from state logic
      let user: User | null = null;
      if (state) {
        // If state passed contains a user ID, we are explicitly linking an existing logged in account
        user = await this.usersService.findOneById(state);
        if (user) {
          user = await this.usersService.updateUser(user.id, { quranId, ...tokenData });
          return await this.generateToken(user);
        }
      }

      // 4. Normal lookup/registration flow
      user = await this.usersService.findOneByQuranId(quranId);
      if (!user && email) {
        user = await this.usersService.findOneByEmail(email);
        if (user) {
          // Auto-link if matching emails
          user = await this.usersService.updateUser(user.id, { quranId, ...tokenData });
          return await this.generateToken(user);
        }
      }

      if (user) {
        // Just cache newest tokens on existing user
        user = await this.usersService.updateUser(user.id, tokenData);
      } else {
        // New creation
        user = await this.usersService.createUser({
          email: email || `${quranId}@quran.foundation`,
          quranId,
          name: quranProfile.name,
          avatar: quranProfile.picture || quranProfile.avatar_url,
          ...tokenData,
        });
      }

      return await this.generateToken(user);

    } catch (error) {
      throw new UnauthorizedException('Failed to authenticate with Quran.Foundation', error?.message);
    }
  }

  async refreshUserQuranToken(userId: string): Promise<string | null> {
    const user = await this.usersService.findOneById(userId);
    if (!user || !user.quranRefreshToken) return null;

    const baseUrl = this.configService.get<string>('Quran_END_POINT') || 'https://prelive-oauth2.quran.foundation';
    const clientId = this.configService.get<string>('QURAN_CLIENT_ID');
    const clientSecret = this.configService.get<string>('QURAN_CLIENT_SECRET');

    try {
      const tokenRes = await firstValueFrom(
        this.httpService.post(`${baseUrl}/oauth2/token`, {
          grant_type: 'refresh_token',
          refresh_token: user.quranRefreshToken,
          client_id: clientId,
          client_secret: clientSecret,
        }),
      );

      const { access_token, refresh_token, expires_in } = tokenRes.data;
      const expiresAt = expires_in ? new Date(Date.now() + expires_in * 1000) : null;

      await this.usersService.updateUser(userId, {
        quranAccessToken: access_token,
        quranRefreshToken: refresh_token || user.quranRefreshToken, // fallback if not rotated
        quranTokenExpiresAt: expiresAt,
      });

      return access_token;
    } catch (error) {
      console.error(`[Quran OAuth] Failed to refresh token for user \${userId}:`, error.message);
      return null;
    }
  }
}
