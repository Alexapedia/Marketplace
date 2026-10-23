type Env = { NODE_ENV?: string; CORS_ORIGINS?: string; SWAGGER_ENABLED?: string };

/**
 * An explicit origin list gets credentials. Without one, development and
 * staging accept any origin but never with credentials, and production
 * accepts no cross-origin requests at all.
 */
export function corsOptions(env: Env): {
  origin: string[] | boolean;
  credentials: boolean;
} {
  const origins = (env.CORS_ORIGINS || '')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
  const explicit = origins.length > 0 && !origins.includes('*');
  if (explicit) {
    return { origin: origins, credentials: true };
  }
  return env.NODE_ENV === 'production'
    ? { origin: false, credentials: false }
    : { origin: true, credentials: false };
}

export function swaggerEnabled(env: Env): boolean {
  return env.NODE_ENV !== 'production' || env.SWAGGER_ENABLED === 'true';
}
