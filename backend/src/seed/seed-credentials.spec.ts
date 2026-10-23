import { resolveSeedPassword } from './seed-credentials';

describe('resolveSeedPassword', () => {
  const fallback = 'Admin@123456';

  it('returns null in production when no password is configured', () => {
    expect(resolveSeedPassword({ NODE_ENV: 'production' }, fallback)).toBeNull();
  });

  it('returns null outside development when the configured value is the public default', () => {
    expect(
      resolveSeedPassword({ NODE_ENV: 'staging', value: 'Admin@123456' }, fallback),
    ).toBeNull();
  });

  it('returns the fallback in development when nothing is configured', () => {
    expect(resolveSeedPassword({ NODE_ENV: 'development' }, fallback)).toBe(fallback);
  });

  it('returns the fallback when NODE_ENV is unset or test', () => {
    expect(resolveSeedPassword({}, fallback)).toBe(fallback);
    expect(resolveSeedPassword({ NODE_ENV: 'test' }, fallback)).toBe(fallback);
  });

  it('returns an explicitly configured password in any environment', () => {
    expect(
      resolveSeedPassword({ NODE_ENV: 'production', value: 'S0me-Strong-Secret!' }, fallback),
    ).toBe('S0me-Strong-Secret!');
  });
});
