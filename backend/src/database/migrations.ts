import { Connection } from 'mongoose';

export const MIGRATIONS_COLLECTION = '_migrations';

/**
 * Runs a one-time data migration and records it, so later boots skip it.
 * The marker is written only after `fn` succeeds, so a failed migration is
 * retried on the next boot.
 */
export async function runMigrationOnce(
  connection: Connection,
  id: string,
  fn: () => Promise<void>,
): Promise<void> {
  const markers = connection.collection<{ _id: string; appliedAt: Date }>(
    MIGRATIONS_COLLECTION,
  );
  if (await markers.findOne({ _id: id })) {
    return;
  }
  await fn();
  await markers.updateOne(
    { _id: id },
    { $setOnInsert: { appliedAt: new Date() } },
    { upsert: true },
  );
}
