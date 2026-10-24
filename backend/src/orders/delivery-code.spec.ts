import { deliveryCodeMatches, newDeliveryCode } from './delivery-code';

describe('delivery code', () => {
  it('is always six digits', () => {
    for (let i = 0; i < 200; i++) {
      expect(newDeliveryCode()).toMatch(/^\d{6}$/);
    }
  });

  it('matches only the exact code, ignoring surrounding spaces', () => {
    expect(deliveryCodeMatches('048213', '048213')).toBe(true);
    expect(deliveryCodeMatches('048213', ' 048213 ')).toBe(true);
    expect(deliveryCodeMatches('048213', '48213')).toBe(false);
    expect(deliveryCodeMatches('048213', '048214')).toBe(false);
  });

  it('never matches when the order has no code', () => {
    expect(deliveryCodeMatches('', '')).toBe(false);
  });
});
