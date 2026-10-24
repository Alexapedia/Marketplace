import * as OTPAuth from 'otpauth';
import { bootApp, TestCtx } from './helpers/app';

describe('Auth (characterization)', () => {
  let ctx: TestCtx;
  const password = 'Passw0rd!test';

  beforeAll(async () => {
    ctx = await bootApp('auth');
  });
  afterAll(async () => {
    await ctx.close();
  });

  const codeFromUrl = (otpauthUrl: string) => {
    const secret = new URL(otpauthUrl).searchParams.get('secret')!;
    return new OTPAuth.TOTP({
      secret: OTPAuth.Secret.fromBase32(secret),
      algorithm: 'SHA1',
      digits: 6,
      period: 30,
    }).generate();
  };

  const login = (email: string, pw = password) =>
    ctx.http().post('/api/v1/auth/login').send({ email, password: pw });

  /** Creates a staff user and completes 2FA setup; returns its email and secret url. */
  const staffWith2fa = async () => {
    const { user } = await ctx.createUser({ role: 'admin', password });
    const first = await login(user.email);
    const { otpauthUrl, challengeToken } = first.body.data;
    const setup = await ctx
      .http()
      .post('/api/v1/auth/2fa/setup')
      .send({ challengeToken, code: codeFromUrl(otpauthUrl) });
    return { user, otpauthUrl, setup };
  };

  it('register returns accessToken and refreshToken', async () => {
    const res = await ctx
      .http()
      .post('/api/v1/auth/register')
      .send({ name: 'Reg', email: 'reg@example.com', password });
    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(typeof res.body.data.accessToken).toBe('string');
    expect(typeof res.body.data.refreshToken).toBe('string');
  });

  it('duplicate email -> 409', async () => {
    const res = await ctx
      .http()
      .post('/api/v1/auth/register')
      .send({ name: 'Reg', email: 'reg@example.com', password });
    expect(res.status).toBe(409);
    expect(res.body.success).toBe(false);
  });

  it('customer login returns a session without 2FA', async () => {
    const { user } = await ctx.createUser({ password });
    const res = await login(user.email);
    expect(res.status).toBe(201);
    expect(typeof res.body.data.accessToken).toBe('string');
    expect(res.body.data.requires2fa).toBeUndefined();
    expect(res.body.data.requires2faSetup).toBeUndefined();
  });

  it('staff login without TOTP returns setup challenge', async () => {
    const { user } = await ctx.createUser({ role: 'admin', password });
    const res = await login(user.email);
    expect(res.status).toBe(201);
    expect(res.body.data.requires2faSetup).toBe(true);
    expect(typeof res.body.data.challengeToken).toBe('string');
    expect(res.body.data.otpauthUrl).toMatch(/^otpauth:\/\/totp\//);
    expect(res.body.data.accessToken).toBeUndefined();
  });

  it('2fa/setup with a valid code returns accessToken and backupCodes', async () => {
    const { setup } = await staffWith2fa();
    expect(setup.status).toBe(201);
    expect(typeof setup.body.data.accessToken).toBe('string');
    expect(setup.body.data.backupCodes).toHaveLength(8);
  });

  it('staff login with TOTP enabled requires 2fa; verify with valid code -> session', async () => {
    const { user, otpauthUrl } = await staffWith2fa();
    const res = await login(user.email);
    expect(res.status).toBe(201);
    expect(res.body.data.requires2fa).toBe(true);
    expect(res.body.data.accessToken).toBeUndefined();
    const verify = await ctx
      .http()
      .post('/api/v1/auth/2fa/verify')
      .send({
        challengeToken: res.body.data.challengeToken,
        code: codeFromUrl(otpauthUrl),
      });
    expect(verify.status).toBe(201);
    expect(typeof verify.body.data.accessToken).toBe('string');
    expect(typeof verify.body.data.refreshToken).toBe('string');
  });

  it('2fa/verify with a wrong code -> 401', async () => {
    const { user, otpauthUrl } = await staffWith2fa();
    const res = await login(user.email);
    const good = codeFromUrl(otpauthUrl);
    const wrong = good === '000000' ? '111111' : '000000';
    const verify = await ctx
      .http()
      .post('/api/v1/auth/2fa/verify')
      .send({ challengeToken: res.body.data.challengeToken, code: wrong });
    expect(verify.status).toBe(401);
    expect(verify.body.success).toBe(false);
  });

  it('forgot-password for unknown email -> 201 generic message', async () => {
    const res = await ctx
      .http()
      .post('/api/v1/auth/forgot-password')
      .send({ email: 'nobody-here@example.com' });
    expect(res.status).toBe(201);
    expect(res.body.data.message).toBe(
      'If the account exists, a reset token was issued',
    );
    expect(res.body.data.resetToken).toBeUndefined();
  });

  it('refresh rotates the refresh token', async () => {
    const reg = await ctx
      .http()
      .post('/api/v1/auth/register')
      .send({ name: 'Rot', email: 'rot@example.com', password });
    const old = reg.body.data.refreshToken;
    const res = await ctx
      .http()
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: old });
    expect(res.status).toBe(201);
    expect(typeof res.body.data.accessToken).toBe('string');
    expect(res.body.data.refreshToken).toBeTruthy();
    expect(res.body.data.refreshToken).not.toBe(old);
    const replay = await ctx
      .http()
      .post('/api/v1/auth/refresh')
      .send({ refreshToken: old });
    expect(replay.status).toBe(401);
  });

  it('POST /auth/firebase when Firebase is disabled -> 501', async () => {
    const res = await ctx
      .http()
      .post('/api/v1/auth/firebase')
      .send({ idToken: 'x' });
    expect(res.status).toBe(501);
  });
});
