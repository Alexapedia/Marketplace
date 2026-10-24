import { FirebaseAdminService } from '../src/firebase/firebase-admin.service';
import { bootApp, TestCtx } from './helpers/app';
import { API } from './helpers/shop';

type Decoded = { uid: string; email?: string; email_verified?: boolean; name?: string };

describe('firebase sign-in', () => {
  let ctx: TestCtx;
  const tokens = new Map<string, Decoded>();
  const fakeFirebase = {
    enabled: true,
    verifyIdToken: async (t: string) => {
      const decoded = tokens.get(t);
      if (!decoded) throw new Error('bad token');
      return decoded;
    },
    sendToTokens: async () => [],
    init: async () => undefined,
    onModuleInit: async () => undefined,
  };

  beforeAll(async () => {
    ctx = await bootApp('firebase_auth', {}, [
      { provide: FirebaseAdminService, useValue: fakeFirebase },
    ]);
  });
  afterAll(async () => {
    await ctx.close();
  });

  const signIn = (idToken: string) =>
    ctx.http().post(`${API}/auth/firebase`).send({ idToken });

  it('an unverified Firebase email does not log into an existing account', async () => {
    const { user } = await ctx.createUser();
    tokens.set('t-unverified', { uid: 'uid-attacker', email: user.email, email_verified: false });

    const res = await signIn('t-unverified');

    expect(res.status).toBe(401);
    const after = await ctx.inTenant(async () => await ctx.model('User').findById(user._id));
    expect(after!.firebaseUid).toBeUndefined();
  });

  it('a verified Firebase email links to the existing customer', async () => {
    const { user } = await ctx.createUser();
    tokens.set('t-verified', { uid: 'uid-owner', email: user.email, email_verified: true });

    const res = await signIn('t-verified').expect(201);

    expect(res.body.data.user._id ?? res.body.data.user.id).toBe(String(user._id));
  });

  it('Firebase sign-in is refused for staff accounts', async () => {
    const { user } = await ctx.createUser({ role: 'admin' });
    tokens.set('t-staff', { uid: 'uid-staff', email: user.email, email_verified: true });

    const res = await signIn('t-staff');

    expect(res.status).toBe(403);
    expect(res.body.data?.accessToken).toBeUndefined();
  });

  it('a new verified Firebase user still gets a customer account', async () => {
    tokens.set('t-new', { uid: 'uid-new', email: `new.${Date.now()}@example.com`, email_verified: true });

    const res = await signIn('t-new').expect(201);

    expect(res.body.data.user.role).toBe('customer');
  });
});
