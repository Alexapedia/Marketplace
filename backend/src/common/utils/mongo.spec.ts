import { generateOrderNumber } from './mongo';

describe('generateOrderNumber', () => {
  it('formats as PM-YYYYMMDD-XXXXXX with 6 uppercase base36 characters', () => {
    expect(generateOrderNumber()).toMatch(/^PM-\d{8}-[0-9A-Z]{6}$/);
  });

  it('produces distinct numbers across 1000 calls', () => {
    const numbers = new Set(Array.from({ length: 1000 }, () => generateOrderNumber()));
    expect(numbers.size).toBe(1000);
  });
});
