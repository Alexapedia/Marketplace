import { Component, inject, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CartService } from '../../core/cart/cart.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { media, pid } from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-cart-page',
  imports: [RouterLink, PageBar, TranslatePipe],
  templateUrl: './cart-page.html',
})
export class CartPage implements OnInit {
  readonly cart = inject(CartService);
  private readonly toast = inject(ToastService);
  private readonly i18n = inject(I18nService);
  readonly media = media;

  ngOnInit(): void {
    this.cart.refresh();
  }

  total(): number {
    return this.cart.items().reduce((n, i) => n + i.unitPrice * i.quantity, 0);
  }

  productId(item: { productId: unknown }): string {
    const p = item.productId;
    if (typeof p === 'string') return p;
    if (p && typeof p === 'object') return pid(p as { _id?: string; id?: string });
    return '';
  }

  dec(itemId: string, qty: number): void {
    if (qty <= 1) return;
    this.cart.updateQty(itemId, qty - 1).subscribe({
      error: (e) => this.toast.show(e.message),
    });
  }

  inc(itemId: string, qty: number): void {
    this.cart.updateQty(itemId, qty + 1).subscribe({
      error: (e) => this.toast.show(e.message),
    });
  }

  remove(itemId: string): void {
    this.cart.remove(itemId).subscribe({
      error: (e) => this.toast.show(e.message),
    });
  }
}
