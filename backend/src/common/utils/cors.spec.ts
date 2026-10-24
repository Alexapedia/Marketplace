import { corsOptions, swaggerEnabled } from './cors';

describe('corsOptions', () => {
  it('allows only listed origins, with credentials, when a list is configured', () => {
    expect(
      corsOptions({ NODE_ENV: 'production', CORS_ORIGINS: 'https://a.com, https://b.com' }),
    ).toEqual({ origin: ['https://a.com', 'https://b.com'], credentials: true });
  });

  it('never reflects every origin together with credentials outside production', () => {
    expect(corsOptions({ NODE_ENV: 'staging', CORS_ORIGINS: '*' })).toEqual({
      origin: true,
      credentials: false,
    });
    expect(corsOptions({ NODE_ENV: 'development' })).toEqual({
      origin: true,
      credentials: false,
    });
  });

  it('allows no cross-origin requests in production without an explicit list', () => {
    expect(corsOptions({ NODE_ENV: 'production', CORS_ORIGINS: '*' })).toEqual({
      origin: false,
      credentials: false,
    });
    expect(corsOptions({ NODE_ENV: 'production' })).toEqual({
      origin: false,
      credentials: false,
    });
  });

  it('uses the explicit list in development too', () => {
    expect(corsOptions({ NODE_ENV: 'development', CORS_ORIGINS: 'http://localhost:4200' })).toEqual({
      origin: ['http://localhost:4200'],
      credentials: true,
    });
  });
});

describe('swaggerEnabled', () => {
  it('is off in production unless explicitly enabled', () => {
    expect(swaggerEnabled({ NODE_ENV: 'production' })).toBe(false);
    expect(swaggerEnabled({ NODE_ENV: 'production', SWAGGER_ENABLED: 'true' })).toBe(true);
  });

  it('is on outside production', () => {
    expect(swaggerEnabled({ NODE_ENV: 'staging' })).toBe(true);
    expect(swaggerEnabled({})).toBe(true);
  });
});
