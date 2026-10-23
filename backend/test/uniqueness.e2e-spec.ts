import { getConnectionToken } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import { bootApp, TestCtx } from './helpers/app';
import { API, auth } from './helpers/shop';

describe('uniqueness of accounts and carts', () => {
  let ctx: TestCtx;

  beforeAll(async () => {
    ctx = await bootApp('uniqueness');
  });
  afterAll(async () => {
    await ctx.close();
  });

  const indexNames = async (collection: string) =>
    (await ctx.app.get<Connection>(getConnectionToken()).collection(collection).indexes()).map(
      (i) => i.name,
    );

  it('ten concurrent registrations with one email create exactly one user', async () => {
    const email = `race.${Date.now()}@example.com`;

    const results = await Promise.all(
      Array.from({ length: 10 }, () =>
        ctx.http().post(`${API}/auth/register`).send({ name: 'Racer', email, password: 'Passw0rd!race' }),
      ),
    );

    const statuses = results.map((r) => r.status).sort();
    expect(statuses).toEqual([201, 409, 409, 409, 409, 409, 409, 409, 409, 409]);
    expect(results.filter((r) => r.status === 409).every((r) => r.body.message === 'Email already registered')).toBe(true);
    const count = await ctx.inTenant(async () => ctx.model('User').countDocuments({ email }));
    expect(count).toBe(1);
  });

  it('concurrent first cart reads create a single cart', async () => {
    const { user, token } = await ctx.createUser();

    await Promise.all(
      Array.from({ length: 6 }, () => ctx.http().get(`${API}/cart`).set(auth(token)).expect(200)),
    );

    const carts = await ctx.inTenant(async () => ctx.model('Cart').countDocuments({ userId: user._id }));
    expect(carts).toBe(1);
  });

  it('the unique email and cart indexes exist (guards the races above)', async () => {
    expect(await indexNames('users')).toContain('tenantId_1_email_1');
    expect(await indexNames('carts')).toContain('tenantId_1_userId_1');
  });
});
