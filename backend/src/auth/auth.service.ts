import {
  ConflictException,
  ForbiddenException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcrypt';
import { createHash, randomBytes } from 'crypto';
import { Model } from 'mongoose';
import { STAFF_ROLES } from '../common/constants';
import type { AuthUser } from '../common/types/auth-user';
import {
  PasswordReset,
  PasswordResetDocument,
} from '../schemas/password-reset.schema';
import { Role, RoleDocument } from '../schemas/role.schema';
import { User, UserDocument } from '../schemas/user.schema';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { TenantContext } from '../tenant/tenant.context';
import { TotpService } from '../tenant/totp.service';
import { FirebaseAuthDto } from './dto/firebase-auth.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { UpdateMeDto } from './dto/update-me.dto';
import { JwtPayload } from './jwt.strategy';

@Injectable()
export class AuthService {
  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    @InjectModel(PasswordReset.name)
    private readonly resetModel: Model<PasswordResetDocument>,
    @InjectModel(Role.name) private readonly roleModel: Model<RoleDocument>,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly firebaseAdmin: FirebaseAdminService,
    private readonly totp: TotpService,
  ) {}

  private staffType(role: string): 'customer' | 'staff' {
    return STAFF_ROLES.includes(role as (typeof STAFF_ROLES)[number])
      ? 'staff'
      : 'customer';
  }

  private tenantIdOf(user: UserDocument): string {
    return String(user.tenantId || TenantContext.requireTenantId());
  }

  private sign(user: UserDocument) {
    const payload: JwtPayload = {
      sub: String(user._id),
      email: user.email,
      role: user.role,
      type: this.staffType(user.role),
      tenantId: this.tenantIdOf(user),
      aud: 'tenant',
    };
    return this.jwt.sign(payload);
  }

  private challengeToken(user: UserDocument, purpose: 'verify' | 'setup') {
    return this.jwt.sign(
      {
        sub: String(user._id),
        email: user.email,
        role: user.role,
        type: this.staffType(user.role),
      tenantId: this.tenantIdOf(user),
      aud: 'tenant-2fa' as const,
        purpose,
      },
      { expiresIn: '5m' },
    );
  }

  private sanitize(user: UserDocument, permissions: string[] = []) {
    const json = user.toJSON() as unknown as Record<string, unknown>;
    delete json.passwordHash;
    return { ...json, permissions };
  }

  private async permissionsFor(role: string) {
    const roleDoc = await this.roleModel.findOne({ name: role }).lean();
    return roleDoc?.permissions ?? [];
  }

  private async present(user: UserDocument) {
    return this.sanitize(user, await this.permissionsFor(user.role));
  }

  async userFromToken(token: string): Promise<AuthUser> {
    const payload = await this.jwt.verifyAsync<JwtPayload>(token);
    if (payload.aud !== 'tenant' || !payload.tenantId) {
      throw new UnauthorizedException('Invalid token');
    }
    return TenantContext.run(
      { kind: 'tenant', tenantId: payload.tenantId },
      async () => {
        const user = await this.userModel.findById(payload.sub);
        if (!user || user.status === 'blocked' || user.status === 'deleted') {
          throw new UnauthorizedException('Account unavailable');
        }
        return {
          userId: String(user._id),
          email: user.email,
          name: user.name,
          role: user.role,
          type: this.staffType(user.role),
          status: user.status,
          permissions: await this.permissionsFor(user.role),
          tenantId: this.tenantIdOf(user),
        };
      },
    );
  }

  async register(dto: RegisterDto) {
    const exists = await this.userModel.findOne({
      email: dto.email.toLowerCase(),
    });
    if (exists) {
      throw new ConflictException('Email already registered');
    }
    const passwordHash = await bcrypt.hash(dto.password, 10);
    const user = await this.userModel.create({
      name: dto.name,
      email: dto.email.toLowerCase(),
      passwordHash,
      phone: dto.phone,
      role: 'customer',
      status: 'active',
    });
    return { user: await this.present(user), accessToken: this.sign(user) };
  }

  async login(dto: LoginDto) {
    const user = await this.userModel
      .findOne({ email: dto.email.toLowerCase() })
      .select('+passwordHash +totpSecret +backupCodeHashes');
    if (!user?.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }
    if (user.lockUntil && user.lockUntil.getTime() > Date.now()) {
      throw new ForbiddenException('Too many attempts. Try again later.');
    }
    const ok = await bcrypt.compare(dto.password, user.passwordHash);
    if (!ok) {
      await this.failLogin(user);
      throw new UnauthorizedException('Invalid credentials');
    }
    if (user.status === 'blocked') {
      throw new ForbiddenException('Account is blocked');
    }
    if (user.status === 'deleted') {
      throw new ForbiddenException('Account deleted');
    }
    user.failedLoginCount = 0;
    user.lockUntil = undefined;
    await user.save();
    if (this.staffType(user.role) === 'staff') {
      if (user.totpEnabled && user.totpSecret) {
        return {
          requires2fa: true,
          challengeToken: this.challengeToken(user, 'verify'),
        };
      }
      return this.beginStaffSetup(user);
    }
    return { user: await this.present(user), accessToken: this.sign(user) };
  }

  async verifyStaff2fa(challengeToken: string, code: string) {
    const user = await this.userFromChallenge(challengeToken, 'verify');
    const secret = user.totpSecret;
    const hashes = user.backupCodeHashes || [];
    const totpOk = secret ? this.totp.verify(secret, code) : false;
    const backupIdx = hashes.indexOf(this.totp.hashCode(code));
    if (!totpOk && backupIdx < 0) {
      await this.failLogin(user);
      throw new UnauthorizedException('Invalid code');
    }
    if (backupIdx >= 0) {
      hashes.splice(backupIdx, 1);
      user.backupCodeHashes = hashes;
    }
    user.failedLoginCount = 0;
    user.lockUntil = undefined;
    await user.save();
    return { user: await this.present(user), accessToken: this.sign(user) };
  }

  async setupStaff2fa(challengeToken: string, code: string) {
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
      user: await this.present(user),
      accessToken: this.sign(user),
      backupCodes: backup,
    };
  }

  async firebase(dto: FirebaseAuthDto) {
    if (!this.firebaseAdmin.enabled) {
      throw new HttpException(
        'Firebase auth is disabled',
        HttpStatus.NOT_IMPLEMENTED,
      );
    }

    let decoded: { uid: string; email?: string; name?: string };
    try {
      decoded = await this.firebaseAdmin.verifyIdToken(dto.idToken);
    } catch {
      throw new UnauthorizedException('Invalid Firebase token');
    }

    const email = decoded.email?.toLowerCase();
    let user = await this.userModel.findOne({
      $or: [
        { firebaseUid: decoded.uid },
        ...(email ? [{ email }] : []),
      ],
    });

    if (!user) {
      user = await this.userModel.create({
        name: decoded.name || email || 'Firebase user',
        email: email || `${decoded.uid}@firebase.local`,
        firebaseUid: decoded.uid,
        role: 'customer',
        status: 'active',
      });
    } else if (!user.firebaseUid) {
      user.firebaseUid = decoded.uid;
      await user.save();
    }

    if (user.status === 'blocked') {
      throw new ForbiddenException('Account is blocked');
    }
    if (user.status === 'deleted') {
      throw new ForbiddenException('Account deleted');
    }

    return { user: await this.present(user), accessToken: this.sign(user) };
  }

  async me(userId: string) {
    const user = await this.userModel.findById(userId);
    if (!user || user.status === 'deleted') {
      throw new NotFoundException('User not found');
    }
    return this.present(user);
  }

  async updateMe(userId: string, dto: UpdateMeDto) {
    const update: Record<string, unknown> = {};
    if (dto.name !== undefined) update.name = dto.name;
    if (dto.phone !== undefined) update.phone = dto.phone;
    if (dto.language !== undefined) update.language = dto.language;
    if (dto.theme !== undefined) update.theme = dto.theme;
    if (dto.avatar !== undefined) update.avatar = dto.avatar;

    const ops: Record<string, unknown> = { $set: update };
    if (dto.fcmToken) {
      ops.$addToSet = { fcmTokens: dto.fcmToken };
    }

    const user = await this.userModel.findByIdAndUpdate(userId, ops, {
      new: true,
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return this.present(user);
  }

  async deleteMe(userId: string) {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    if (STAFF_ROLES.includes(user.role as (typeof STAFF_ROLES)[number])) {
      throw new ForbiddenException('Staff accounts cannot be deleted here');
    }
    if (user.status === 'deleted') {
      return { deleted: true };
    }
    user.status = 'deleted';
    user.deletedAt = new Date();
    user.fcmTokens = [];
    user.passwordHash = undefined;
    user.firebaseUid = undefined;
    user.email = `deleted.${String(user._id)}.${Date.now()}@deleted.local`;
    user.name = 'Deleted user';
    await user.save();
    return { deleted: true };
  }

  async forgotPassword(email: string) {
    const user = await this.userModel.findOne({ email: email.toLowerCase() });
    const generic = {
      message: 'If the account exists, a reset token was issued',
    };
    if (!user || user.status === 'deleted') {
      return generic;
    }

    const token = randomBytes(32).toString('hex');
    const tokenHash = createHash('sha256').update(token).digest('hex');
    await this.resetModel.deleteMany({ userId: user._id });
    await this.resetModel.create({
      userId: user._id,
      tokenHash,
      expiresAt: new Date(Date.now() + 60 * 60 * 1000),
    });

    const isDev = this.config.get<string>('NODE_ENV') !== 'production';
    return isDev ? { ...generic, resetToken: token } : generic;
  }

  async resetPassword(dto: ResetPasswordDto) {
    const tokenHash = createHash('sha256').update(dto.token).digest('hex');
    const record = await this.resetModel.findOne({ tokenHash });
    if (!record || record.expiresAt.getTime() < Date.now()) {
      throw new UnauthorizedException('Invalid or expired token');
    }
    const passwordHash = await bcrypt.hash(dto.password, 10);
    await this.userModel.findByIdAndUpdate(record.userId, { passwordHash });
    await this.resetModel.deleteMany({ userId: record.userId });
    return { message: 'Password updated' };
  }

  private async beginStaffSetup(user: UserDocument) {
    const secret = this.totp.generateSecret();
    user.totpSecret = secret;
    user.totpEnabled = false;
    await user.save();
    const otpauthUrl = this.totp.keyuri(user.email, secret, 'PlaceMarket');
    return {
      requires2faSetup: true,
      challengeToken: this.challengeToken(user, 'setup'),
      otpauthUrl,
      qr: await this.totp.qrDataUrl(otpauthUrl),
    };
  }

  private async userFromChallenge(token: string, purpose: 'verify' | 'setup') {
    let payload: JwtPayload & { purpose?: string };
    try {
      payload = await this.jwt.verifyAsync(token);
    } catch {
      throw new UnauthorizedException('Challenge expired');
    }
    if (payload.aud !== 'tenant-2fa' || payload.purpose !== purpose || !payload.tenantId) {
      throw new UnauthorizedException('Invalid challenge');
    }
    const ctxTenant = TenantContext.tenantId();
    if (ctxTenant && payload.tenantId !== ctxTenant) {
      throw new UnauthorizedException('Invalid challenge');
    }
    return TenantContext.run({ kind: 'tenant', tenantId: payload.tenantId }, async () => {
      const user = await this.userModel
        .findById(payload.sub)
        .select('+totpSecret +backupCodeHashes +passwordHash');
      if (!user || user.status !== 'active') {
        throw new UnauthorizedException('Account unavailable');
      }
      return user;
    });
  }

  private async failLogin(user: UserDocument) {
    user.failedLoginCount = (user.failedLoginCount || 0) + 1;
    if (user.failedLoginCount >= 5) {
      user.lockUntil = new Date(Date.now() + 15 * 60 * 1000);
      user.failedLoginCount = 0;
    }
    await user.save();
  }
}
