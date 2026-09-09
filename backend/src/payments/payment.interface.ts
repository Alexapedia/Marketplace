export type PaymentMethod = 'COD' | 'ONLINE';
export type PaymentStatus =
  | 'pending'
  | 'paid'
  | 'failed'
  | 'refunded'
  | 'cancelled';

export interface PaymentChargeInput {
  orderId: string;
  amount: number;
  currency: string;
  method: PaymentMethod;
  metadata?: Record<string, unknown>;
}

export interface PaymentChargeResult {
  paymentStatus: PaymentStatus;
  transactionReference?: string;
}

export interface PaymentProvider {
  readonly name: string;
  charge(input: PaymentChargeInput): Promise<PaymentChargeResult>;
  handleWebhook?(payload: unknown): Promise<PaymentChargeResult>;
}

export class CodPaymentProvider implements PaymentProvider {
  readonly name = 'COD';

  async charge(input: PaymentChargeInput): Promise<PaymentChargeResult> {
    return {
      paymentStatus: 'pending',
      transactionReference: `COD-${input.orderId}`,
    };
  }
}
