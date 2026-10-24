import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';
import { PlatformModule } from '../src/platform/platform.module';
import { TenantContext } from '../src/tenant/tenant.context';
import { bootApp, TestCtx } from './helpers/app';
import { API, auth } from './helpers/shop';

describe('platform branding (holder logo)', () => {
  let ctx: TestCtx;
  let holderToken: string;

  beforeAll(async () => {
    ctx = await bootApp('platform_branding');
    const holder = await TenantContext.run({ kind: 'platform' }, async () =>
      ctx.model('PlatformUser').create({
        name: 'Holder',
        email: `holder.${Date.now()}@example.com`,
        passwordHash: await bcrypt.hash('Passw0rd!holder', 10),
        role: 'platform_owner',
        status: 'active',
      }),
    );
    holderToken = ctx.app
      .select(PlatformModule)
      .get(JwtService)
      .sign({
        sub: String(holder._id),
        email: holder.email,
        role: holder.role,
        aud: 'platform',
      });
  });
  afterAll(async () => {
    await ctx.close();
  });

  const png = Buffer.from('89504e470d0a1a0a', 'hex');

  it('the holder can upload a logo image', async () => {
    const res = await ctx
      .http()
      .post(`${API}/platform/uploads`)
      .set(auth(holderToken))
      .attach('file', png, { filename: 'logo.png', contentType: 'image/png' });

    expect(res.status).toBe(201);
    expect(res.body.data.url).toMatch(/\/uploads\/[0-9a-f-]+\.png$/);
  });

  it('platform uploads reject anonymous callers and tenant tokens', async () => {
    const { token: customerToken } = await ctx.createUser();

    await ctx
      .http()
      .post(`${API}/platform/uploads`)
      .attach('file', png, { filename: 'logo.png', contentType: 'image/png' })
      .expect(401);
    await ctx
      .http()
      .post(`${API}/platform/uploads`)
      .set(auth(customerToken))
      .attach('file', png, { filename: 'logo.png', contentType: 'image/png' })
      .expect(401);
  });

  it('platform uploads refuse non-image files', async () => {
    const res = await ctx
      .http()
      .post(`${API}/platform/uploads`)
      .set(auth(holderToken))
      .attach('file', Buffer.from('%PDF-1.4'), {
        filename: 'x.pdf',
        contentType: 'application/pdf',
      });

    expect(res.status).toBe(400);
  });

  it('saving colours keeps the existing logo (branding is merged, not replaced)', async () => {
    const path = `${API}/platform/tenants/${ctx.tenantId}`;
    await ctx
      .http()
      .patch(path)
      .set(auth(holderToken))
      .send({
        branding: {
          logo: 'http://cdn.test/logo.png',
          logoDark: 'http://cdn.test/logo-dark.png',
        },
      })
      .expect(200);

    const res = await ctx
      .http()
      .patch(path)
      .set(auth(holderToken))
      .send({
        branding: { name: 'Renamed', primary: '#112233', accent: '#ddaa55' },
      })
      .expect(200);

    expect(res.body.data.branding).toMatchObject({
      name: 'Renamed',
      primary: '#112233',
      accent: '#ddaa55',
      logo: 'http://cdn.test/logo.png',
      logoDark: 'http://cdn.test/logo-dark.png',
    });
  });

  it('unknown branding keys are ignored', async () => {
    const res = await ctx
      .http()
      .patch(`${API}/platform/tenants/${ctx.tenantId}`)
      .set(auth(holderToken))
      .send({ branding: { logo: 'http://cdn.test/l.png', script: '<x>' } })
      .expect(200);

    expect(res.body.data.branding.script).toBeUndefined();
  });
});
