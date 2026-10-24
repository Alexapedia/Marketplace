import { TenantContext } from '../src/tenant/tenant.context';
import { bootApp, TestCtx } from './helpers/app';

const CONFIG = '/api/v1/app/config';

describe('X-Tenant header (store chosen by slug)', () => {
  let ctx: TestCtx;

  beforeAll(async () => {
    ctx = await bootApp('tenant_header');
    await TenantContext.run({ kind: 'platform' }, () =>
      ctx.model('Tenant').create({
        slug: 'paytoll',
        name: 'PayToll',
        status: 'active',
        domains: [{ host: 'shop.paytoll.test', channel: 'website' }],
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

  it('picks the store named by X-Tenant when no host matches (mobile)', async () => {
    const res = await ctx
      .http()
      .get(CONFIG)
      .set('X-Client', 'mobile')
      .set('X-Tenant', 'paytoll')
      .expect(200);
    expect(storeName(res)).toBe('PayToll');
  });

  it('ignores case and surrounding spaces in the slug', async () => {
    const res = await ctx
      .http()
      .get(CONFIG)
      .set('X-Tenant', '  PayToll ')
      .expect(200);
    expect(storeName(res)).toBe('PayToll');
  });

  it('rejects an unknown slug instead of serving the default store', async () => {
    await ctx.http().get(CONFIG).set('X-Tenant', 'nope').expect(404);
  });

  it('a matched host wins over X-Tenant, so a domain cannot switch stores', async () => {
    const res = await ctx
      .http()
      .get(CONFIG)
      .set('Origin', 'http://localhost:5173')
      .set('X-Tenant', 'paytoll')
      .expect(200);
    expect(storeName(res)).toBe('Zezo Store');
  });

  it('without the header the default store is served, as before', async () => {
    const res = await ctx
      .http()
      .get(CONFIG)
      .set('X-Client', 'mobile')
      .expect(200);
    expect(storeName(res)).toBe('Zezo Store');
  });
});
