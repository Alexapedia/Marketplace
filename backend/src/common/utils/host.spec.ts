import { normalizeHost } from './host';

describe('normalizeHost', () => {
  it('lowercases a bare host and keeps the port', () => {
    expect(normalizeHost('PayToll.localhost:5173')).toBe(
      'paytoll.localhost:5173',
    );
  });

  it('reads the host out of a full URL', () => {
    expect(normalizeHost('http://paytoll.localhost:5173/shop?x=1')).toBe(
      'paytoll.localhost:5173',
    );
  });

  it('ignores surrounding whitespace', () => {
    expect(normalizeHost('  paytoll.localhost:5173 ')).toBe(
      'paytoll.localhost:5173',
    );
    expect(normalizeHost(' https://paytoll.com/ ')).toBe('paytoll.com');
  });

  it('returns an empty string for missing or blank input', () => {
    expect(normalizeHost(undefined)).toBe('');
    expect(normalizeHost('   ')).toBe('');
  });
});
