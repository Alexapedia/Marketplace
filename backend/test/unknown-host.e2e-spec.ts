import { TenantContext } from '../src/tenant/tenant.context';
import { bootApp, TestCtx } from './helpers/app';

const CONFIG = '/api/v1/app/config';

describe('unknown store hosts with API_HOSTS set (production)', () => {
  let ctx: TestCtx;

  beforeAll(async () => {
    ctx = await bootApp('unknown_host', { API_HOSTS: 'api.example.test' });
    await TenantContext.run({ kind: 'platform' }, () =>
      ctx.model('Tenant').create({
        slug: 'paytoll',
        name: 'PayToll',
        status: 'active',
        domains: [{ host: 'paytoll.example.test', channel: 'website' }],
        channels: { website: true, admin: true, mobile: true },
        branding: { name: 'PayToll' },
      }),
    );
  });
  afterAll(async () => {
    await ctx.close();
  });

  const storeName = (res: { body: { data: { tenant: { name: string } } } }) =>
    res.body.data.tenant.name;

  it('a host that matches no store is "unknown store", not the default store', async () => {
    await ctx.http().get(CONFIG).set('Host', 'typo.example.test').expect(404);
  });

  it('a browser on an unknown domain is refused even with an X-Tenant header', async () => {
    await ctx
      .http()
      .get(CONFIG)
      .set('Host', 'typo.example.test')
      .set('X-Tenant', 'paytoll')
      .expect(404);
  });

  it("a store's own domain still opens that store", async () => {
    const res = await ctx
      .http()
      .get(CONFIG)
      .set('Host', 'paytoll.example.test')
      .expect(200);
    expect(storeName(res)).toBe('PayToll');
  });

  it('the API host serves the store named by X-Tenant (mobile)', async () => {
    const res = await ctx
      .http()
      .get(CONFIG)
      .set('Host', 'api.example.test')
      .set('X-Tenant', 'paytoll')
      .expect(200);
    expect(storeName(res)).toBe('PayToll');
  });

  it('the API host without X-Tenant keeps the default store (existing apps)', async () => {
    const res = await ctx
      .http()
      .get(CONFIG)
      .set('Host', 'api.example.test')
      .expect(200);
    expect(storeName(res)).toBe('Zezo Store');
  });

  it('the health check does not depend on the host', async () => {
    await ctx
      .http()
      .get('/api/v1/health')
      .set('Host', 'typo.example.test')
      .expect(200);
  });
});
