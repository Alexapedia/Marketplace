import {
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcrypt';
import { Model } from 'mongoose';
import {
  PlatformUser,
  PlatformUserDocument,
} from '../schemas/platform-user.schema';
import { TotpService } from '../tenant/totp.service';
import { LoginDto } from '../auth/dto/login.dto';
import { PlatformJwtPayload } from './platform-jwt.strategy';

@Injectable()
export class PlatformAuthService {
  constructor(
    @InjectModel(PlatformUser.name)
    private readonly users: Model<PlatformUserDocument>,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly totp: TotpService,
  ) {}

  private secret() {
    return (
      this.config.get<string>('JWT_PLATFORM_SECRET') ||
      this.config.get<string>('JWT_SECRET') ||
      'change-me-in-production'
    );
  }

  private sign(user: PlatformUserDocument) {
    const payload: PlatformJwtPayload = {
      sub: String(user._id),
      email: user.email,
      role: user.role,
      aud: 'platform',
    };
    return this.jwt.sign(payload, { secret: this.secret(), expiresIn: '8h' });
  }

  private challenge(user: PlatformUserDocument, purpose: 'verify' | 'setup') {
    return this.jwt.sign(
      {
        sub: String(user._id),
        email: user.email,
        role: user.role,
        aud: 'platform-2fa',
        purpose,
      },
      { secret: this.secret(), expiresIn: '5m' },
    );
  }

  private present(user: PlatformUserDocument) {
    return {
      id: String(user._id),
      name: user.name,
      email: user.email,
      role: user.role,
      totpEnabled: user.totpEnabled,
    };
  }

  async login(dto: LoginDto) {
    const user = await this.users
      .findOne({ email: dto.email.toLowerCase() })
      .select('+passwordHash +totpSecret +backupCodeHashes');
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    if (user.lockUntil && user.lockUntil.getTime() > Date.now()) {
      throw new ForbiddenException('Too many attempts. Try again later.');
    }
    const ok = await bcrypt.compare(dto.password, user.passwordHash);
    if (!ok) {
      await this.fail(user);
      throw new UnauthorizedException('Invalid credentials');
    }
    if (user.status !== 'active') {
      throw new ForbiddenException('Account unavailable');
    }
    user.failedLoginCount = 0;
    user.lockUntil = undefined;
    if (user.totpEnabled && user.totpSecret) {
      await user.save();
      return { requires2fa: true, challengeToken: this.challenge(user, 'verify') };
    }
    const secret = this.totp.generateSecret();
    user.totpSecret = secret;
    user.totpEnabled = false;
    await user.save();
    const otpauthUrl = this.totp.keyuri(user.email, secret, 'PlaceMarket Holder');
    return {
      requires2faSetup: true,
      challengeToken: this.challenge(user, 'setup'),
      otpauthUrl,
      qr: await this.totp.qrDataUrl(otpauthUrl),
    };
  }

  async verify(challengeToken: string, code: string) {
    const user = await this.userFromChallenge(challengeToken, 'verify');
    const totpOk = user.totpSecret ? this.totp.verify(user.totpSecret, code) : false;
    const hashes = user.backupCodeHashes || [];
    const backupIdx = hashes.indexOf(this.totp.hashCode(code));
    if (!totpOk && backupIdx < 0) {
      await this.fail(user);
      throw new UnauthorizedException('Invalid code');
    }
    if (backupIdx >= 0) {
      hashes.splice(backupIdx, 1);
      user.backupCodeHashes = hashes;
    }
    user.failedLoginCount = 0;
    user.lockUntil = undefined;
    await user.save();
    return { user: this.present(user), accessToken: this.sign(user) };
  }

  async setup(challengeToken: string, code: string) {
    const user = await this.userFromChallenge(challengeToken, 'setup');
    if (!user.totpSecret || !this.totp.verify(user.totpSecret, code)) {
      throw new UnauthorizedException('Invalid authenticator code');
    }
    const backup = this.totp.backupCodes();
    user.totpEnabled = true;
    user.backupCodeHashes = backup.map((c) => this.totp.hashCode(c));
    user.failedLoginCount = 0;
    user.lockUntil = undefined;
    await user.save();
    return {
      user: this.present(user),
      accessToken: this.sign(user),
      backupCodes: backup,
    };
  }

  async me(userId: string) {
    const user = await this.users.findById(userId);
    if (!user) throw new UnauthorizedException('Account unavailable');
    return this.present(user);
  }

  private async userFromChallenge(token: string, purpose: 'verify' | 'setup') {
    let payload: PlatformJwtPayload;
    try {
      payload = await this.jwt.verifyAsync(token, { secret: this.secret() });
    } catch {
      throw new UnauthorizedException('Challenge expired');
    }
    if (payload.aud !== 'platform-2fa' || payload.purpose !== purpose) {
      throw new UnauthorizedException('Invalid challenge');
    }
    const user = await this.users
      .findById(payload.sub)
      .select('+totpSecret +backupCodeHashes +passwordHash');
    if (!user || user.status !== 'active') {
      throw new UnauthorizedException('Account unavailable');
    }
    return user;
  }

  private async fail(user: PlatformUserDocument) {
    user.failedLoginCount = (user.failedLoginCount || 0) + 1;
    if (user.failedLoginCount >= 5) {
      user.lockUntil = new Date(Date.now() + 15 * 60 * 1000);
      user.failedLoginCount = 0;
    }
    await user.save();
  }
}
