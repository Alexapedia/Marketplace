import { Component, Input, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiClient } from '../core/api/api-client';
import { AuthService } from '../core/auth/auth.service';
import { CartService } from '../core/cart/cart.service';
import { I18nService } from '../core/i18n/i18n.service';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import {
  media,
  onSale,
  pid,
  priceOf,
  Product,
  productName,
} from '../core/models/models';
import { ToastService } from '../core/toast/toast.service';
import { Stars } from './stars';

@Component({
  selector: 'app-product-card',
  imports: [RouterLink, TranslatePipe, Stars],
  template: `
    <article class="pc">
      <div class="pic">
        <a [routerLink]="['/product', id]">
          @if (img) {
            <img [src]="img" alt="" />
          }
        </a>
        @if (sale) {
          <span class="sale">{{ 'sale' | t }}</span>
        }
        @if (auth.user()) {
          <button
            class="h"
            [class.on]="liked"
            type="button"
            (click)="toggleFav($event)"
            aria-label="favorite"
          >
            ♥
          </button>
        }
      </div>
      <a class="pn" [routerLink]="['/product', id]">{{ name }}</a>
      <app-stars [value]="product.ratingAvg ?? 0" />
      <div class="r">
        <em>
          {{ price }} {{ 'currency' | t }}
          @if (sale) {
            <span class="old">{{ product.price }}</span>
          }
        </em>
        @if (auth.user()) {
          <button class="btn" type="button" (click)="add($event)">{{ 'addToCart' | t }}</button>
        } @else {
          <a class="btn" routerLink="/login">{{ 'addToCart' | t }}</a>
        }
      </div>
    </article>
  `,
})
export class ProductCard {
  @Input({ required: true }) product!: Product;
  @Input() liked = false;

  readonly auth = inject(AuthService);
  private readonly api = inject(ApiClient);
  private readonly cart = inject(CartService);
  private readonly toast = inject(ToastService);
  private readonly i18n = inject(I18nService);

  get id(): string {
    return pid(this.product);
  }

  get img(): string {
    return media(this.product.images?.[0]);
  }

  get name(): string {
    return productName(this.product, this.i18n.lang()) || '—';
  }

  get price(): number {
    return priceOf(this.product);
  }

  get sale(): boolean {
    return onSale(this.product);
  }

  add(ev: Event): void {
    ev.preventDefault();
    ev.stopPropagation();
    this.cart.add(this.id, 1).subscribe({
      next: () => this.toast.show(this.i18n.t('added')),
      error: (e) => this.toast.show(e.message || this.i18n.t('error')),
    });
  }

  toggleFav(ev: Event): void {
    ev.preventDefault();
    ev.stopPropagation();
    const req = this.liked
      ? this.api.delete(`/favorites/${this.id}`)
      : this.api.post('/favorites', { productId: this.id });
    req.subscribe({
      next: () => {
        this.liked = !this.liked;
      },
      error: (e) => this.toast.show(e.message || this.i18n.t('login')),
    });
  }
}
