import { bootApp, createProduct, TestCtx } from './helpers/app';

describe('test harness', () => {
  let ctx: TestCtx;
  beforeAll(async () => {
    ctx = await bootApp('harness');
  });
  afterAll(async () => {
    await ctx.close();
  });

  it('createUser token authenticates /auth/me', async () => {
    const { user, token } = await ctx.createUser();
    const res = await ctx
      .http()
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect(JSON.stringify(res.body)).toContain(user.email);
  });

  it('createProduct is publicly readable', async () => {
    const p = await createProduct(ctx, { price: 100, stock: 5 });
    await ctx.http().get(`/api/v1/products/${p._id}`).expect(200);
  });
});
