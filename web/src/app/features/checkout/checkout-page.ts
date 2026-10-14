import { Component, inject, OnInit, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ApiClient } from '../../core/api/api-client';
import { CartService } from '../../core/cart/cart.service';
import { StoreConfigService } from '../../core/config/store-config.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { Address, asItems, media, Order } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { PageBar } from '../../shared/page-bar';
import { PriceSummary } from '../../shared/price-summary';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-checkout-page',
  imports: [FormsModule, RouterLink, PageBar, TranslatePipe, PriceSummary, AsyncState],
  templateUrl: './checkout-page.html',
})
export class CheckoutPage implements OnInit {
  private readonly api = inject(ApiClient);
  readonly cart = inject(CartService);
  readonly store = inject(StoreConfigService);
  private readonly router = inject(Router);
  private readonly toast = inject(ToastService);
  private readonly i18n = inject(I18nService);
  readonly media = media;

  addresses = signal<Address[]>([]);
  loadingAddresses = signal(true);
  addressError = signal<string | null>(null);
  submitting = signal(false);
  addressId = '';
  notes = '';
  error = '';
  // One key per checkout visit so a double submit cannot create two orders.
  private readonly idempotencyKey = `web-${Date.now()}-${Math.random().toString(36).slice(2)}`;

  ngOnInit(): void {
    this.cart.refresh();
    this.store.refresh();
    this.loadAddresses();
  }

  loadAddresses(): void {
    this.loadingAddresses.set(true);
    this.addressError.set(null);
    this.api.get<Address[]>('/addresses').subscribe({
      next: (res) => {
        const list = asItems<Address>(res.data);
        this.addresses.set(list);
        const def = list.find((a) => a.isDefault) ?? list[0];
        this.addressId = String(def?._id || def?.id || '');
        this.loadingAddresses.set(false);
      },
      error: (e: Error) => {
        this.addressError.set(e.message);
        this.loadingAddresses.set(false);
      },
    });
  }

  subtotal(): number {
    return this.cart.items().reduce((n, i) => n + i.unitPrice * i.quantity, 0);
  }

  total(): number {
    return this.subtotal() + this.store.deliveryFee();
  }

  submit(ev: Event): void {
    ev.preventDefault();
    if (this.submitting()) return;
    if (!this.cart.items().length) {
      void this.router.navigate(['/cart']);
      return;
    }
    if (!this.addressId) {
      this.toast.show(this.i18n.t('noAddresses'));
      void this.router.navigate(['/address']);
      return;
    }
    this.error = '';
    this.submitting.set(true);
    this.api
      .post<Order>(
        '/orders',
        { addressId: this.addressId, notes: this.notes, paymentMethod: 'COD', channel: 'website' },
        { 'Idempotency-Key': this.idempotencyKey },
      )
      .subscribe({
        next: (res) => {
          this.cart.refresh();
          this.toast.show(this.i18n.t('successOrder'));
          const id = res.data?._id;
          void this.router.navigate(id ? ['/orders', id] : ['/orders']);
        },
        error: (e) => {
          this.error = e.message;
          this.submitting.set(false);
        },
      });
  }
}
