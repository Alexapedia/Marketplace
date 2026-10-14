import { BadRequestException } from '@nestjs/common';
import { Types } from 'mongoose';

export function toObjectId(id: string, field = 'id'): Types.ObjectId {
  if (!Types.ObjectId.isValid(id)) {
    throw new BadRequestException(`Invalid ${field}`);
  }
  return new Types.ObjectId(id);
}

export function generateOrderNumber(): string {
  const now = new Date();
  const ymd = now.toISOString().slice(0, 10).replace(/-/g, '');
  const rand = Math.floor(1000 + Math.random() * 9000);
  return `PM-${ymd}-${rand}`;
}

/** Case-insensitive regex for user-supplied search text (special chars escaped). */
export function searchRegex(text: string): RegExp {
  return new RegExp(text.trim().slice(0, 100).replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
}
