/**
 * Whether first boot fills the default store with demo categories, products,
 * banners, ads and reviews. Never in production unless SEED_DEMO=true;
 * SEED_DEMO=false turns it off anywhere.
 */
export function shouldSeedDemo(env: {
  NODE_ENV?: string;
  SEED_DEMO?: string;
}): boolean {
  const flag = env.SEED_DEMO?.trim().toLowerCase();
  if (flag === 'true') return true;
  if (flag === 'false') return false;
  return env.NODE_ENV !== 'production';
}
