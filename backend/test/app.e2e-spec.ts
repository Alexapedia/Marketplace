import { bootApp, TestCtx } from './helpers/app';

describe('API (e2e)', () => {
  let ctx: TestCtx;
  const email = `e2e.${Date.now()}@example.com`;
  const password = 'Passw0rd!e2e';

  beforeAll(async () => {
    ctx = await bootApp('api');
  });

  afterAll(async () => {
    await ctx.close();
  });

  const http = () => ctx.http();

  it('GET /health', () => http().get('/api/v1/health').expect(200));

  it('register → refresh rotates → old token rejected → logout', async () => {
    const reg = await http()
      .post('/api/v1/auth/register')
      .send({ name: 'E2E', email, password })
      .expect(201);
    const first = reg.body.data.refreshToken as string;
    expect(reg.body.data.accessToken).toBeTruthy();
    expect(first).toBeTruthy();

    const refreshed = await http()
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: first })
      .expect(201);
    const second = refreshed.body.data.refreshToken as string;
    expect(second).not.toEqual(first);

    await http()
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: first })
      .expect(401);

    await http()
      .post('/api/v1/auth/logout')
      .set('Authorization', `Bearer ${refreshed.body.data.accessToken}`)
      .send({ refreshToken: second })
      .expect(201);

    await http()
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: second })
      .expect(401);
  });

  it('forgot-password issues a token that resets the password', async () => {
    const forgot = await http()
      .post('/api/v1/auth/forgot-password')
      .send({ email })
      .expect(201);
    const token = forgot.body.data.resetToken as string;
    expect(token).toBeTruthy();
    await http()
      .post('/api/v1/auth/reset-password')
      .send({ token, password: 'N3wPassw0rd!' })
      .expect(201);
    await http()
      .post('/api/v1/auth/login')
      .send({ email, password: 'N3wPassw0rd!' })
      .expect(201);
  });

  it('GET /products supports price filters and escapes search', async () => {
    const res = await http()
      .get('/api/v1/products?minPrice=0&maxPrice=1000000&search=(%5B&sort=-ratingAvg')
      .expect(200);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.meta).toBeDefined();
  });
});
