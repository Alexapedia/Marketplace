import { bootApp, TestCtx } from './helpers/app';
import { API } from './helpers/shop';

describe('auth hardening (staging config)', () => {
  let ctx: TestCtx;

  beforeAll(async () => {
    ctx = await bootApp('auth_hardening', { NODE_ENV: 'staging', EXPOSE_RESET_TOKEN: undefined });
  });
  afterAll(async () => {
    await ctx.close();
  });

  it('forgot-password never returns the reset token outside an explicit opt-in', async () => {
    const { user } = await ctx.createUser();

    const res = await ctx
      .http()
      .post(`${API}/auth/forgot-password`)
      .send({ email: user.email })
      .expect(201);

    expect(res.body.data.resetToken).toBeUndefined();
  });
});
