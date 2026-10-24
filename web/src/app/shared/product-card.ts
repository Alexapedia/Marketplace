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
import { Icon } from './icon';

@Component({
  selector: 'app-product-card',
  imports: [RouterLink, TranslatePipe, Stars, Icon],
  template: `
    <article class="pc m-lift">
      <div class="pic m-zoom">
        <a
          class="pic-link"
          [routerLink]="['/product', id]"
          (click)="markShared($event)"
          [attr.aria-label]="name"
          tabindex="-1"
        >
          @if (img) {
            <img [src]="img" alt="" loading="lazy" decoding="async" />
          } @else {
            <span class="pic-ph" aria-hidden="true">{{ name.charAt(0) }}</span>
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
            [attr.aria-label]="'favorites' | t"
            [attr.aria-pressed]="liked"
          >
            <m-icon name="heart" />
          </button>
        }
      </div>
      <div class="pc-body">
        <a class="pn" [routerLink]="['/product', id]" (click)="markShared($event)">{{ name }}</a>
        <app-stars [value]="product.ratingAvg ?? 0" />
        <div class="r">
          <span class="price">
            {{ price }} <small>{{ 'currency' | t }}</small>
            @if (sale) {
              <span class="old">{{ product.price }}</span>
            }
          </span>
          @if (auth.user()) {
            <button
              class="add"
              type="button"
              (click)="add($event)"
              [attr.aria-label]="'addToCart' | t"
              [title]="'addToCart' | t"
            >
              <m-icon name="bagPlus" />
            </button>
          } @else {
            <a class="add" routerLink="/login" [attr.aria-label]="'addToCart' | t" [title]="'addToCart' | t">
              <m-icon name="bagPlus" />
            </a>
          }
        </div>
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

  /**
   * Presentation only: names this card's image for the route view transition
   * so it morphs into the product gallery image. Only one element carries the
   * name at a time, which keeps it unique on pages that repeat a product.
   */
  markShared(ev: Event): void {
    const card = (ev.currentTarget as HTMLElement | null)?.closest('.pc');
    for (const el of Array.from(document.querySelectorAll<HTMLElement>('.pc .pic img'))) {
      el.style.viewTransitionName = '';
    }
    const img = card?.querySelector<HTMLElement>('.pic img');
    if (img) img.style.viewTransitionName = 'm-product';
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
