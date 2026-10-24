import * as bcrypt from 'bcrypt';
import { Secret, TOTP } from 'otpauth';
import { TenantContext } from '../src/tenant/tenant.context';
import { bootApp, TestCtx } from './helpers/app';
import { API } from './helpers/shop';

const code = (secret: string) =>
  new TOTP({ secret: Secret.fromBase32(secret), algorithm: 'SHA1', digits: 6, period: 30 }).generate();

describe('2FA lockout', () => {
  let ctx: TestCtx;

  beforeAll(async () => {
    ctx = await bootApp('twofa_lockout');
  });
  afterAll(async () => {
    await ctx.close();
  });

  it('staff 2FA verify is refused while the account is locked, even with a valid code', async () => {
    const secret = new Secret({ size: 20 }).base32;
    const { user } = await ctx.createUser({ role: 'admin', password: 'Passw0rd!lock' });
    await ctx.inTenant(async () =>
      ctx.model('User').updateOne({ _id: user._id }, { totpSecret: secret, totpEnabled: true }),
    );
    const login = await ctx
      .http()
      .post(`${API}/auth/login`)
      .send({ email: user.email, password: 'Passw0rd!lock' })
      .expect(201);
    const challengeToken = login.body.data.challengeToken as string;

    for (let i = 0; i < 5; i++) {
      await ctx.http().post(`${API}/auth/2fa/verify`).send({ challengeToken, code: '000000' });
    }
    const res = await ctx
      .http()
      .post(`${API}/auth/2fa/verify`)
      .send({ challengeToken, code: code(secret) });

    expect(res.status).toBe(403);
    expect(res.body.data?.accessToken).toBeUndefined();
  });

  it('platform 2FA verify is refused while the account is locked, even with a valid code', async () => {
    const secret = new Secret({ size: 20 }).base32;
    const email = `holder.${Date.now()}@example.com`;
    await TenantContext.run({ kind: 'platform' }, async () =>
      ctx.model('PlatformUser').create({
        name: 'Holder',
        email,
        passwordHash: await bcrypt.hash('Passw0rd!holder', 10),
        role: 'platform_owner',
        status: 'active',
        totpEnabled: true,
        totpSecret: secret,
      }),
    );
    const login = await ctx
      .http()
      .post(`${API}/platform/auth/login`)
      .send({ email, password: 'Passw0rd!holder' })
      .expect(201);
    const challengeToken = login.body.data.challengeToken as string;

    for (let i = 0; i < 5; i++) {
      await ctx.http().post(`${API}/platform/auth/2fa/verify`).send({ challengeToken, code: '000000' });
    }
    const res = await ctx
      .http()
      .post(`${API}/platform/auth/2fa/verify`)
      .send({ challengeToken, code: code(secret) });

    expect(res.status).toBe(403);
  });
});
