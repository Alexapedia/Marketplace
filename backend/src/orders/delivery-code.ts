import { randomInt, timingSafeEqual } from 'crypto';

/** Six random digits the customer reads out to confirm a delivery. */
export function newDeliveryCode(): string {
  return String(randomInt(0, 1_000_000)).padStart(6, '0');
}

/** Constant-time comparison, so response timing gives nothing away. */
export function deliveryCodeMatches(expected: string, given: string): boolean {
  const a = Buffer.from(String(expected || ''));
  const b = Buffer.from(String(given || '').trim());
  return a.length > 0 && a.length === b.length && timingSafeEqual(a, b);
}
