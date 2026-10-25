import { shouldSeedDemo } from './seed-demo';

describe('shouldSeedDemo', () => {
  it('never fills a production store with demo content by default', () => {
    expect(shouldSeedDemo({ NODE_ENV: 'production' })).toBe(false);
  });

  it('keeps demo content for development, test and staging', () => {
    expect(shouldSeedDemo({})).toBe(true);
    expect(shouldSeedDemo({ NODE_ENV: 'development' })).toBe(true);
    expect(shouldSeedDemo({ NODE_ENV: 'test' })).toBe(true);
    expect(shouldSeedDemo({ NODE_ENV: 'staging' })).toBe(true);
  });

  it('SEED_DEMO overrides the default either way', () => {
    expect(shouldSeedDemo({ NODE_ENV: 'production', SEED_DEMO: 'true' })).toBe(
      true,
    );
    expect(
      shouldSeedDemo({ NODE_ENV: 'development', SEED_DEMO: 'false' }),
    ).toBe(false);
  });
});
