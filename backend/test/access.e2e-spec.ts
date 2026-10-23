import { bootApp, TestCtx } from './helpers/app';

const PNG_B64 =
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

describe('Access control (characterization)', () => {
  let ctx: TestCtx;

  beforeAll(async () => {
    ctx = await bootApp('access');
  });
  afterAll(async () => {
    await ctx.close();
  });

  it('customer token on GET /admin/orders -> 403', async () => {
    const { token } = await ctx.createUser({ role: 'customer' });
    const res = await ctx
      .http()
      .get('/api/v1/admin/orders')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(403);
  });

  it('no token on GET /orders -> 401', async () => {
    const res = await ctx.http().get('/api/v1/orders');
    expect(res.status).toBe(401);
  });

  it('customer can upload a PNG and receives a url', async () => {
    const { token } = await ctx.createUser({ role: 'customer' });
    const res = await ctx
      .http()
      .post('/api/v1/uploads')
      .set('Authorization', `Bearer ${token}`)
      .attach('file', Buffer.from(PNG_B64, 'base64'), {
        filename: 'a.png',
        contentType: 'image/png',
      });
    expect(res.status).toBe(201);
    const url: string = res.body.data.url;
    expect(url).toMatch(/\.png$/);
    const path = new URL(url).pathname;
    expect(path).toMatch(/^\/uploads\//);
    await ctx.http().get(path).expect(200);
  });

  it('super_admin can block a customer, who then gets 401 on /auth/me', async () => {
    const admin = await ctx.createUser({ role: 'super_admin' });
    const customer = await ctx.createUser({ role: 'customer' });
    const before = await ctx
      .http()
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${customer.token}`);
    expect(before.status).toBe(200);

    const patch = await ctx
      .http()
      .patch(`/api/v1/admin/customers/${customer.user._id}`)
      .set('Authorization', `Bearer ${admin.token}`)
      .send({ status: 'blocked' });
    expect(patch.status).toBe(200);
    expect(patch.body.data.status).toBe('blocked');

    const after = await ctx
      .http()
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${customer.token}`);
    expect(after.status).toBe(401);
  });
});
