import { Module } from '@nestjs/common';
import { CodPaymentProvider } from './payment.interface';

export const PAYMENT_PROVIDER = 'PAYMENT_PROVIDER';

@Module({
  providers: [{ provide: PAYMENT_PROVIDER, useClass: CodPaymentProvider }],
  exports: [PAYMENT_PROVIDER],
})
export class PaymentsModule {}
