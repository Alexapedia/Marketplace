/** Passwords published in the README; never acceptable outside development. */
const PUBLIC_DEFAULTS = new Set(['Admin@123456', 'Holder@123456']);

const DEV_ENVS = new Set(['development', 'test', '']);

/**
 * Picks the password for a seeded account. Returns null when seeding would
 * create a guessable account (a public default outside development), so the
 * caller skips that account instead.
 */
export function resolveSeedPassword(
  env: { NODE_ENV?: string; value?: string },
  fallback: string,
): string | null {
  const isDev = DEV_ENVS.has(env.NODE_ENV ?? '');
  const value = env.value?.trim();
  if (value) {
    return isDev || !PUBLIC_DEFAULTS.has(value) ? value : null;
  }
  return isDev ? fallback : null;
}
