import { Component, inject, OnInit, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ApiClient } from '../../core/api/api-client';
import { CartService } from '../../core/cart/cart.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { Address, asItems } from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-checkout-page',
  imports: [FormsModule, RouterLink, PageBar, TranslatePipe],
  templateUrl: './checkout-page.html',
})
export class CheckoutPage implements OnInit {
  private readonly api = inject(ApiClient);
  private readonly cart = inject(CartService);
  private readonly router = inject(Router);
  private readonly toast = inject(ToastService);
  private readonly i18n = inject(I18nService);

  addresses = signal<Address[]>([]);
  addressId = '';
  notes = '';
  error = '';

  ngOnInit(): void {
    this.cart.refresh();
    this.api.get<Address[]>('/addresses').subscribe({
      next: (res) => {
        const list = asItems<Address>(res.data);
        this.addresses.set(list);
        const def = list.find((a) => a.isDefault) ?? list[0];
        this.addressId = String(def?._id || def?.id || '');
      },
    });
  }

  submit(ev: Event): void {
    ev.preventDefault();
    if (!this.addressId) {
      this.toast.show(this.i18n.t('noAddresses'));
      void this.router.navigate(['/address']);
      return;
    }
    this.api
      .post('/orders', {
        addressId: this.addressId,
        notes: this.notes,
        paymentMethod: 'COD',
        channel: 'website',
      })
      .subscribe({
        next: () => {
          this.cart.refresh();
          this.toast.show(this.i18n.t('successOrder'));
          void this.router.navigate(['/orders']);
        },
        error: (e) => {
          this.error = e.message;
        },
      });
  }
}
