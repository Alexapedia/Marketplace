import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { PassportStrategy } from '@nestjs/passport';
import { Model } from 'mongoose';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PlatformUser, PlatformUserDocument } from '../schemas/platform-user.schema';

export type PlatformJwtPayload = {
  sub: string;
  email: string;
  role: string;
  aud: 'platform' | 'platform-2fa';
  purpose?: 'verify' | 'setup';
};

export type PlatformAuthUser = {
  userId: string;
  email: string;
  name: string;
  role: string;
};

@Injectable()
export class PlatformJwtStrategy extends PassportStrategy(Strategy, 'platform-jwt') {
  constructor(
    config: ConfigService,
    @InjectModel(PlatformUser.name)
    private readonly users: Model<PlatformUserDocument>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey:
        config.get<string>('JWT_PLATFORM_SECRET') ||
        config.get<string>('JWT_SECRET') ||
        'change-me-in-production',
    });
  }

  async validate(payload: PlatformJwtPayload): Promise<PlatformAuthUser> {
    if (payload.aud !== 'platform') {
      throw new UnauthorizedException('Invalid token');
    }
    const user = await this.users.findById(payload.sub);
    if (!user || user.status !== 'active') {
      throw new UnauthorizedException('Account unavailable');
    }
    return {
      userId: String(user._id),
      email: user.email,
      name: user.name,
      role: user.role,
    };
  }
}
