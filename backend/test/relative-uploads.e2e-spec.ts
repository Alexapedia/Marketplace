import { getConnectionToken } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import { bootApp, TestCtx } from './helpers/app';

const FILE = '817fdec8-fbef-4ee6-9943-4dc294abb565.png';

describe('relative upload URLs migration', () => {
  let first: TestCtx | undefined;
  let second: TestCtx | undefined;

  const db = (ctx: TestCtx) => ctx.app.get<Connection>(getConnectionToken());

  beforeAll(async () => {
    try {
      first = await bootApp('relative_uploads');
      // Data as it was stored before the migration existed.
      await db(first)
        .collection('_migrations')
        .deleteOne({ _id: 'relative-uploads-v1' as never });
      await db(first)
        .collection('legacy_media')
        .insertOne({
          name: 'old',
          branding: { logo: `http://localhost:3000/uploads/${FILE}` },
          images: [
            `http://localhost:3010/uploads/${FILE}`,
            'https://x.io/a.png',
          ],
        });
      await first.close({ keepDatabase: true });
      first = undefined;
      second = await bootApp('relative_uploads');
    } finally {
      await first?.close();
    }
  });

  afterAll(async () => {
    await second?.close();
  });

  it('rewrites stored absolute upload URLs to /uploads paths on boot', async () => {
    const doc = await db(second!)
      .collection('legacy_media')
      .findOne({ name: 'old' });
    expect(doc!.branding).toEqual({ logo: `/uploads/${FILE}` });
    expect(doc!.images).toEqual([`/uploads/${FILE}`, 'https://x.io/a.png']);
  });

  it('records the migration so later boots skip it', async () => {
    const marker = await db(second!)
      .collection('_migrations')
      .findOne({ _id: 'relative-uploads-v1' as never });
    expect(marker).toBeTruthy();
  });
});
