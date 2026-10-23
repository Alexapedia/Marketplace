import { getConnectionToken } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import { bootApp, TestCtx } from './helpers/app';

describe('boot migrations', () => {
  let first: TestCtx | undefined;
  let second: TestCtx | undefined;
  let markerAfterFirstBoot: unknown;
  let legacyDocAfterSecondBoot: Record<string, unknown> | null = null;

  const db = (ctx: TestCtx) => ctx.app.get<Connection>(getConnectionToken());

  beforeAll(async () => {
    try {
      first = await bootApp('boot');
      markerAfterFirstBoot = await db(first)
        .collection('_migrations')
        .findOne({ _id: 'boot-v1' as never });
      // Legacy-shaped data written after the one-time migration ran.
      await db(first).collection('legacy_things').insertOne({ name: 'no tenant' });
      await first.close({ keepDatabase: true });
      first = undefined;

      second = await bootApp('boot');
      legacyDocAfterSecondBoot = await db(second)
        .collection('legacy_things')
        .findOne({ name: 'no tenant' });
    } finally {
      await first?.close();
    }
  });

  afterAll(async () => {
    await second?.close();
  });

  it('records that the one-time migration ran', () => {
    expect(markerAfterFirstBoot).toBeTruthy();
  });

  it('does not re-run the tenant backfill on later boots', () => {
    expect(legacyDocAfterSecondBoot).not.toBeNull();
    expect(legacyDocAfterSecondBoot!.tenantId).toBeUndefined();
  });
});
