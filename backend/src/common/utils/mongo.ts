import { BadRequestException } from '@nestjs/common';
import { randomBytes } from 'crypto';
import { Types } from 'mongoose';

export function toObjectId(id: string, field = 'id'): Types.ObjectId {
  if (!Types.ObjectId.isValid(id)) {
    throw new BadRequestException(`Invalid ${field}`);
  }
  return new Types.ObjectId(id);
}

const ORDER_ALPHABET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/** PM-YYYYMMDD-XXXXXX: 36^6 (~2.2 billion) crypto-random suffixes per day. */
export function generateOrderNumber(): string {
  const ymd = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const bytes = randomBytes(6);
  let suffix = '';
  for (const b of bytes) {
    suffix += ORDER_ALPHABET[b % ORDER_ALPHABET.length];
  }
  return `PM-${ymd}-${suffix}`;
}

/** Case-insensitive regex for user-supplied search text (special chars escaped). */
export function searchRegex(text: string): RegExp {
  return new RegExp(text.trim().slice(0, 100).replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
}
