import type { OrderStatus } from '../common/constants';

/** Fulfilment order; an order may skip ahead but never move back. */
const FLOW: OrderStatus[] = [
  'pending',
  'accepted',
  'preparing',
  'ready',
  'out_for_delivery',
  'delivered',
  'completed',
];

const TERMINAL = new Set<OrderStatus>(['completed', 'cancelled', 'rejected']);

/**
 * Whether an order may move from `from` to `to`. Terminal orders never move;
 * cancel/reject are allowed until the order is delivered.
 */
export function canTransition(from: OrderStatus, to: OrderStatus): boolean {
  if (from === to || TERMINAL.has(from)) {
    return false;
  }
  const fromIdx = FLOW.indexOf(from);
  if (to === 'cancelled' || to === 'rejected') {
    return fromIdx < FLOW.indexOf('delivered');
  }
  return FLOW.indexOf(to) > fromIdx;
}
