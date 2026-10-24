import { bootApp, TestCtx } from './helpers/app';
import { API, auth } from './helpers/shop';

describe('uploads security', () => {
  let ctx: TestCtx;
  let token: string;

  beforeAll(async () => {
    ctx = await bootApp('uploads');
    ({ token } = await ctx.createUser());
  });
  afterAll(async () => {
    await ctx.close();
  });

  const upload = (filename: string, contentType: string, body: Buffer) =>
    ctx
      .http()
      .post(`${API}/uploads`)
      .set(auth(token))
      .attach('file', body, { filename, contentType });

  it('an html file declared as image/png is stored with a .png extension', async () => {
    const res = await upload('x.html', 'image/png', Buffer.from('<script>alert(1)</script>'));

    expect(res.status).toBe(201);
    expect(res.body.data.url).toMatch(/\.png$/);
  });

  it('a javascript file declared as image/jpeg is stored as .jpg', async () => {
    const res = await upload('evil.js', 'image/jpeg', Buffer.from('alert(1)'));

    expect(res.body.data.url).toMatch(/\.jpg$/);
  });

  it('uploads are served with nosniff and a locked-down CSP', async () => {
    const res = await upload('x.html', 'image/png', Buffer.from('<script>alert(1)</script>'));
    const path: string = res.body.data.url;

    const get = await ctx.http().get(path).expect(200);

    expect(get.headers['content-type']).toMatch(/^image\/png/);
    expect(get.headers['x-content-type-options']).toBe('nosniff');
    expect(get.headers['content-security-policy']).toContain("default-src 'none'");
    expect(get.headers['content-security-policy']).toContain('sandbox');
  });
});
