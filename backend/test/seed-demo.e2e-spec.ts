import { bootApp, TestCtx } from './helpers/app';

describe('first boot without demo content (SEED_DEMO=false)', () => {
  let ctx: TestCtx;

  beforeAll(async () => {
    ctx = await bootApp('seed_demo', { SEED_DEMO: 'false' });
  });
  afterAll(async () => {
    await ctx.close();
  });

  const count = (model: string) =>
    ctx.inTenant(() => ctx.model(model).countDocuments().exec());

  it('still creates the roles the store needs', async () => {
    expect(await count('Role')).toBeGreaterThan(0);
  });

  it('adds no demo products, categories, ads or reviews', async () => {
    expect(await count('Product')).toBe(0);
    expect(await count('Category')).toBe(0);
    expect(await count('Ad')).toBe(0);
    expect(await count('Review')).toBe(0);
  });

  it('the store config still answers, with empty banners', async () => {
    const res = await ctx.http().get('/api/v1/app/config').expect(200);
    expect(res.body.data.banners ?? []).toEqual([]);
  });
});
