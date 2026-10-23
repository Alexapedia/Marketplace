import { INestApplication, ValidationPipe } from '@nestjs/common';
import { getConnectionToken, getModelToken } from '@nestjs/mongoose';
import type { JwtService } from '@nestjs/jwt';
import { Test } from '@nestjs/testing';
import * as bcrypt from 'bcrypt';
import { Connection, Model } from 'mongoose';
import request from 'supertest';
import { AuthService } from '../../src/auth/auth.service';
import { STAFF_ROLES } from '../../src/common/constants';
import { TenantContext } from '../../src/tenant/tenant.context';

export interface TestCtx {
  app: INestApplication;
  http(): ReturnType<typeof request>;
  tenantId: string;
  inTenant<T>(fn: () => Promise<T>): Promise<T>;
  model<T = any>(name: string): Model<T>;
  createUser(opts?: {
    role?: string;
    email?: string;
    password?: string;
    name?: string;
  }): Promise<{ user: any; token: string }>;
  tokenFor(user: any): string;
  close(): Promise<void>;
}

export async function bootApp(
  suite: string,
  env: Record<string, string | undefined> = {},
): Promise<TestCtx> {
  process.env.MONGODB_URI = `${process.env.E2E_MONGODB_BASE || 'mongodb://127.0.0.1:27017'}/placemarket_e2e_${suite}`;
  process.env.NODE_ENV = 'test';
  process.env.EXPOSE_RESET_TOKEN = 'true';
  for (const [k, v] of Object.entries(env)) {
    if (v === undefined) delete process.env[k];
    else process.env[k] = v;
  }

  // Required only after env is set so ConfigModule picks up the e2e database.
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const { AppModule } = require('../../src/app.module');
  const moduleFixture = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();
  const app = moduleFixture.createNestApplication();
  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );
  await app.init();

  const slug = (process.env.DEFAULT_TENANT_SLUG || 'zezo').toLowerCase();
  const tenant: any = await TenantContext.run({ kind: 'platform' }, () =>
    app.get(getModelToken('Tenant')).findOne({ slug }).lean().exec(),
  );
  if (!tenant) throw new Error(`Default tenant '${slug}' not found after boot`);
  const tenantId = String(tenant._id);

  const inTenant = <T>(fn: () => Promise<T>): Promise<T> =>
    TenantContext.run({ kind: 'tenant', tenantId, slug }, fn);
  const model = <T = any>(name: string): Model<T> =>
    app.get(getModelToken(name));

  const tokenFor = (user: any): string =>
    // Reuse AuthService's JwtService: PlatformModule registers a second JwtModule
    // (different secret/expiry), so app.get(JwtService) is ambiguous.
    ((app.get(AuthService) as any).jwt as JwtService).sign({
      sub: String(user._id),
      email: user.email,
      role: user.role,
      type: (STAFF_ROLES as readonly string[]).includes(user.role)
        ? 'staff'
        : 'customer',
      tenantId,
      aud: 'tenant',
    });

  const createUser: TestCtx['createUser'] = async (opts = {}) => {
    const passwordHash = await bcrypt.hash(opts.password ?? 'Passw0rd!test', 10);
    const user = await inTenant(() =>
      model('User').create({
        name: opts.name ?? 'Test User',
        email:
          opts.email ??
          `u.${Date.now()}.${Math.random().toString(36).slice(2, 8)}@example.com`,
        passwordHash,
        role: opts.role ?? 'customer',
        status: 'active',
      }),
    );
    return { user, token: tokenFor(user) };
  };

  return {
    app,
    http: () => request(app.getHttpServer()),
    tenantId,
    inTenant,
    model,
    createUser,
    tokenFor,
    close: async () => {
      await app.get<Connection>(getConnectionToken()).dropDatabase();
      await app.close();
    },
  };
}

export async function createProduct(
  ctx: TestCtx,
  opts: {
    price: number;
    stock: number;
    salePrice?: number;
    variants?: Array<{ name: string; sku?: string; price?: number; stock?: number }>;
    name?: string;
  },
): Promise<any> {
  return ctx.inTenant(async () => {
    const Category = ctx.model('Category');
    let category: any = await Category.findOne();
    if (!category) {
      category = await Category.create({
        names: { en: 'Test Category', ar: 'فئة اختبار' },
        status: 'published',
      });
    }
    const name = opts.name ?? `Test Product ${Math.random().toString(36).slice(2, 8)}`;
    return ctx.model('Product').create({
      categoryId: category._id,
      names: { en: name, ar: name },
      price: opts.price,
      stock: opts.stock,
      salePrice: opts.salePrice,
      variants: opts.variants ?? [],
      status: 'published',
    });
  });
}
