import { Component, input } from '@angular/core';
import { TranslatePipe } from '../core/i18n/translate.pipe';

@Component({
  selector: 'app-price-summary',
  imports: [TranslatePipe],
  template: `
    <dl class="summary">
      <div><dt>{{ 'subtotal' | t }}</dt><dd>{{ subtotal() }} {{ 'currency' | t }}</dd></div>
      @if (discount()) {
        <div class="disc"><dt>{{ 'discount' | t }}</dt><dd>−{{ discount() }} {{ 'currency' | t }}</dd></div>
      }
      <div>
        <dt>{{ 'deliveryFee' | t }}</dt>
        <dd>{{ deliveryFee() ? deliveryFee() + ' ' + ('currency' | t) : ('free' | t) }}</dd>
      </div>
      <div class="total"><dt>{{ 'total' | t }}</dt><dd>{{ total() }} {{ 'currency' | t }}</dd></div>
    </dl>
  `,
})
export class PriceSummary {
  readonly subtotal = input(0);
  readonly discount = input(0);
  readonly deliveryFee = input(0);
  readonly total = input(0);
}
