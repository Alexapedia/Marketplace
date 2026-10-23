import { bootApp, TestCtx } from './helpers/app';
import { API } from './helpers/shop';

describe('rate limiting behind a proxy', () => {
  let ctx: TestCtx;

  beforeAll(async () => {
    ctx = await bootApp('throttle');
  });
  afterAll(async () => {
    await ctx.close();
  });

  const login = (clientIp: string) =>
    ctx
      .http()
      .post(`${API}/auth/login`)
      .set('X-Forwarded-For', clientIp)
      .send({ email: 'nobody@example.com', password: 'wrong-password' });

  it('limits each client separately when requests arrive through a trusted proxy', async () => {
    for (let i = 0; i < 10; i++) {
      expect((await login('203.0.113.1')).status).not.toBe(429);
    }

    expect((await login('203.0.113.1')).status).toBe(429);
    expect((await login('203.0.113.2')).status).not.toBe(429);
  });
});
