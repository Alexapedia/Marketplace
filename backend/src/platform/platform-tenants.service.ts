import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcrypt';
import { Model } from 'mongoose';
import { ALL_PERMISSIONS } from '../common/constants';
import { AppConfig, AppConfigDocument } from '../schemas/app-config.schema';
import { Order, OrderDocument } from '../schemas/order.schema';
import {
  PlatformAudit,
  PlatformAuditDocument,
} from '../schemas/platform-audit.schema';
import { Product, ProductDocument } from '../schemas/product.schema';
import { Role, RoleDocument } from '../schemas/role.schema';
import { Tenant, TenantDocument } from '../schemas/tenant.schema';
import { User, UserDocument } from '../schemas/user.schema';
import { TenantContext } from '../tenant/tenant.context';
import { AppChannel } from '../tenant/tenant.context';
import { TenantService } from '../tenant/tenant.service';
import { PlatformInsightsService } from './platform-insights.service';

@Injectable()
export class PlatformTenantsService {
  constructor(
    private readonly tenants: TenantService,
    @InjectModel(Tenant.name) private readonly tenantModel: Model<TenantDocument>,
    @InjectModel(User.name) private readonly users: Model<UserDocument>,
    @InjectModel(Product.name) private readonly products: Model<ProductDocument>,
    @InjectModel(Order.name) private readonly orders: Model<OrderDocument>,
    @InjectModel(Role.name) private readonly roles: Model<RoleDocument>,
    @InjectModel(AppConfig.name) private readonly configs: Model<AppConfigDocument>,
    @InjectModel(PlatformAudit.name)
    private readonly auditModel: Model<PlatformAuditDocument>,
    private readonly insights: PlatformInsightsService,
  ) {}

  overview() {
    return this.insights.overview();
  }

  async list() {
    const rows = await this.tenants.list();
    return TenantContext.run({ kind: 'platform' }, async () => {
      const details: Array<Record<string, unknown>> = [];
      for (const row of rows) {
        const id = String(row._id);
        const [customers, products, orders] = await Promise.all([
          this.users.countDocuments({
            tenantId: id,
            role: 'customer',
            status: { $ne: 'deleted' },
          }),
          this.products.countDocuments({ tenantId: id }),
          this.orders.countDocuments({ tenantId: id }),
        ]);
        details.push({
          ...this.tenants.publicView(row),
          domains: row.domains,
          customers,
          products,
          orders,
          createdAt: row.createdAt,
        });
      }
      return details;
    });
  }

  async get(id: string) {
    const tenant = await this.tenants.findById(id);
    if (!tenant) throw new NotFoundException('Tenant not found');
    return TenantContext.run({ kind: 'platform' }, async () => {
      const [customers, staff, products, orders] = await Promise.all([
        this.users.countDocuments({
          tenantId: id,
          role: 'customer',
          status: { $ne: 'deleted' },
        }),
        this.users
          .find({
            tenantId: id,
            role: { $ne: 'customer' },
            status: { $ne: 'deleted' },
          })
          .select('name email role status totpEnabled lastLoginAt createdAt')
          .lean(),
        this.products.countDocuments({ tenantId: id }),
        this.orders.countDocuments({ tenantId: id }),
      ]);
      return {
        ...this.tenants.publicView(tenant),
        domains: tenant.domains,
        customers,
        products,
        orders,
        staff,
        createdAt: tenant.createdAt,
      };
    });
  }

  async create(
    actorId: string,
    ip: string | undefined,
    body: {
      slug: string;
      name: string;
      adminEmail: string;
      adminPassword: string;
      adminName?: string;
      domains?: Array<{ host: string; channel: 'website' | 'admin' }>;
      branding?: Record<string, string>;
      currency?: string;
    },
  ) {
    const tenant = await this.tenants.create({
      slug: body.slug,
      name: body.name,
      domains: body.domains,
      branding: body.branding,
      currency: body.currency,
    });
    const tenantId = String(tenant._id);
    await TenantContext.run({ kind: 'tenant', tenantId }, async () => {
      await this.seedRoles(tenantId);
      await this.users.create({
        name: body.adminName || `${body.name} Admin`,
        email: body.adminEmail.toLowerCase(),
        passwordHash: await bcrypt.hash(body.adminPassword, 10),
        role: 'super_admin',
        status: 'active',
        totpEnabled: false,
      } as never);
      await this.configs.create({
        key: 'global',
        banners: [],
        onboarding: [],
        version: {},
        settings: {
          deliveryFee: 0,
          currency: tenant.currency || 'SAR',
          supportPhone: '',
          supportEmail: '',
        },
      } as never);
    });
    await this.audit(actorId, 'tenant.create', tenantId, { slug: tenant.slug }, ip);
    return this.get(tenantId);
  }

  async patch(actorId: string, ip: string | undefined, id: string, patch: Record<string, unknown>) {
    const allowed = ['name', 'domains', 'branding', 'currency'];
    const set: Record<string, unknown> = {};
    for (const key of allowed) {
      if (patch[key] !== undefined) set[key] = patch[key];
    }
    const doc = await this.tenants.update(id, set);
    await this.audit(actorId, 'tenant.update', id, set, ip);
    return this.tenants.publicView(doc);
  }

  async setChannel(
    actorId: string,
    ip: string | undefined,
    id: string,
    channel: AppChannel,
    enabled: boolean,
  ) {
    const doc = await this.tenants.setChannel(id, channel, enabled);
    await this.audit(actorId, enabled ? 'channel.enable' : 'channel.disable', id, { channel }, ip);
    return this.tenants.publicView(doc);
  }

  async setStatus(
    actorId: string,
    ip: string | undefined,
    id: string,
    status: 'active' | 'suspended',
  ) {
    const doc = await this.tenants.setStatus(id, status);
    await this.audit(actorId, `tenant.${status}`, id, { status }, ip);
    return this.tenants.publicView(doc);
  }

  async audits(tenantId?: string) {
    const filter = tenantId ? { tenantId } : {};
    return this.auditModel.find(filter).sort({ createdAt: -1 }).limit(100).lean();
  }

  async resetStaff2fa(actorId: string, ip: string | undefined, tenantId: string, userId: string) {
    return TenantContext.run({ kind: 'platform' }, async () => {
      const user = await this.users.findOne({ _id: userId, tenantId, role: { $ne: 'customer' } });
      if (!user) throw new NotFoundException('Staff not found');
      user.totpEnabled = false;
      user.totpSecret = undefined;
      user.backupCodeHashes = [];
      await user.save();
      await this.audit(actorId, 'staff.reset2fa', tenantId, { userId }, ip);
      return { reset: true };
    });
  }

  private async audit(
    actorId: string,
    action: string,
    tenantId: string | undefined,
    meta: unknown,
    ip?: string,
  ) {
    await this.auditModel.create({ actorId, action, tenantId, meta, ip });
  }

  private async seedRoles(tenantId: string) {
    const defs: Array<{ name: string; permissions: string[] }> = [
      { name: 'super_admin', permissions: [...ALL_PERMISSIONS] },
      {
        name: 'admin',
        permissions: ALL_PERMISSIONS.filter((p) => p !== 'roles.write'),
      },
      { name: 'customer', permissions: [] },
      {
        name: 'support_agent',
        permissions: [
          'dashboard.read',
          'chats.read',
          'chats.write',
          'custom-orders.read',
          'custom-orders.write',
          'customers.read',
          'reviews.read',
          'reviews.write',
        ],
      },
      {
        name: 'order_manager',
        permissions: [
          'dashboard.read',
          'orders.read',
          'orders.write',
          'customers.read',
          'reports.read',
          'reviews.read',
        ],
      },
      {
        name: 'product_manager',
        permissions: [
          'dashboard.read',
          'products.read',
          'products.write',
          'categories.read',
          'categories.write',
          'custom-fields.read',
          'custom-fields.write',
          'reviews.read',
        ],
      },
      {
        name: 'marketing_manager',
        permissions: [
          'dashboard.read',
          'notifications.write',
          'app-config.read',
          'app-config.write',
          'ads.read',
          'ads.write',
          'reviews.read',
          'reviews.write',
        ],
      },
    ];
    for (const role of defs) {
      await this.roles.updateOne(
        { tenantId, name: role.name },
        { $set: { ...role, tenantId, isSystem: true } },
        { upsert: true },
      );
    }
  }
}
