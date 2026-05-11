import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from './dto/register.dto';
import { User } from '@prisma/client';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
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

    return this.generateToken(user);
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
    return this.generateToken(user);
  }

  generateToken(user: Partial<User>) {
    const payload = { sub: user.id, email: user.email };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    };
  }

  getQuranOAuthUrl(redirectUri: string, state?: string) {
    const baseUrl = this.configService.get<string>('Quran_END_POINT') || 'https://prelive-oauth2.quran.foundation';
    const clientId = this.configService.get<string>('QURAN_CLIENT_ID');
    const query: Record<string, string> = {
      client_id: clientId || '',
      redirect_uri: redirectUri,
      response_type: 'code',
      scope: 'openid profile email',
    };
    if (state) {
      query.state = state;
    }
    const q = new URLSearchParams(query);
    return `${baseUrl}/oauth/authorize?${q.toString()}`;
  }

  async handleQuranCallback(code: string, redirectUri: string, state?: string) {
    const baseUrl = this.configService.get<string>('Quran_END_POINT') || 'https://prelive-oauth2.quran.foundation';
    const clientId = this.configService.get<string>('QURAN_CLIENT_ID');
    const clientSecret = this.configService.get<string>('QURAN_CLIENT_SECRET');

    try {
      // 1. Exchange code for token
      const tokenRes = await firstValueFrom(
        this.httpService.post(`${baseUrl}/oauth/token`, {
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
        this.httpService.get(`${baseUrl}/oauth/userinfo`, {
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
          return this.generateToken(user);
        }
      }

      // 4. Normal lookup/registration flow
      user = await this.usersService.findOneByQuranId(quranId);
      if (!user && email) {
        user = await this.usersService.findOneByEmail(email);
        if (user) {
          // Auto-link if matching emails
          user = await this.usersService.updateUser(user.id, { quranId, ...tokenData });
          return this.generateToken(user);
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

      return this.generateToken(user);

    } catch (error) {
      throw new UnauthorizedException('Failed to authenticate with Quran.Foundation', error?.message);
    }
  }
}
