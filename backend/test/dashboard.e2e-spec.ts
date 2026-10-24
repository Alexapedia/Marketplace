import { bootApp, TestCtx } from './helpers/app';

describe('Admin dashboard cache', () => {
  let ctx: TestCtx;
  let token: string;

  beforeAll(async () => {
    ctx = await bootApp('dashboard');
    ({ token } = await ctx.createUser({ role: 'super_admin' }));
  });
  afterAll(async () => {
    jest.restoreAllMocks();
    await ctx.close();
  });

  const get = () =>
    ctx
      .http()
      .get('/api/v1/admin/dashboard')
      .set('Authorization', `Bearer ${token}`);

  it('two dashboard calls within 30s run the aggregations once', async () => {
    const spy = jest.spyOn(ctx.model('Order'), 'aggregate');
    const r1 = await get();
    expect(r1.status).toBe(200);
    const first = spy.mock.calls.length;
    expect(first).toBeGreaterThan(0);
    const r2 = await get();
    expect(r2.status).toBe(200);
    expect(spy.mock.calls.length).toBe(first);
  });

  it('responses are identical for cached calls', async () => {
    const a = await get();
    const b = await get();
    expect(b.body).toEqual(a.body);
  });

  it('the cache expires after 30 seconds', async () => {
    const spy = jest.spyOn(ctx.model('Order'), 'aggregate');
    await get();
    const before = spy.mock.calls.length;
    const real = Date.now();
    jest.spyOn(Date, 'now').mockReturnValue(real + 31_000);
    await get();
    expect(spy.mock.calls.length).toBeGreaterThan(before);
  });
});
