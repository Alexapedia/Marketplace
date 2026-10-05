import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { PassportStrategy } from '@nestjs/passport';
import { Model } from 'mongoose';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { STAFF_ROLES } from '../common/constants';
import { AuthUser } from '../common/types/auth-user';
import { Role, RoleDocument } from '../schemas/role.schema';
import { User, UserDocument } from '../schemas/user.schema';
import { TenantContext } from '../tenant/tenant.context';

export interface JwtPayload {
  sub: string;
  email: string;
  role: string;
  type: 'customer' | 'staff';
  tenantId: string;
  aud: 'tenant' | 'tenant-2fa' | 'platform' | 'platform-2fa';
  purpose?: 'verify' | 'setup';
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    config: ConfigService,
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    @InjectModel(Role.name) private readonly roleModel: Model<RoleDocument>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.get<string>('JWT_SECRET') || 'change-me-in-production',
    });
  }

  async validate(payload: JwtPayload): Promise<AuthUser> {
    if (payload.aud !== 'tenant') {
      throw new UnauthorizedException('Invalid token');
    }
    const ctxTenant = TenantContext.tenantId();
    if (ctxTenant && payload.tenantId !== ctxTenant) {
      throw new UnauthorizedException('Invalid token');
    }
    const user = await this.userModel.findById(payload.sub);
    if (!user || user.status === 'blocked' || user.status === 'deleted') {
      throw new UnauthorizedException('Account unavailable');
    }
    const roleDoc = await this.roleModel.findOne({ name: user.role }).lean();
    return {
      userId: String(user._id),
      email: user.email,
      name: user.name,
      role: user.role,
      type: STAFF_ROLES.includes(user.role as (typeof STAFF_ROLES)[number])
        ? 'staff'
        : 'customer',
      status: user.status,
      permissions: roleDoc?.permissions ?? [],
      tenantId: String(user.tenantId || payload.tenantId),
    };
  }
}
