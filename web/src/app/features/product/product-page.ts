import { Component, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ApiClient } from '../../core/api/api-client';
import { AuthService } from '../../core/auth/auth.service';
import { CartService } from '../../core/cart/cart.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import {
  media,
  onSale,
  priceOf,
  Product,
  ProductVariant,
  productDesc,
  productName,
  Review,
  ReviewsPayload,
} from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { Stars } from '../../shared/stars';
import { AsyncState } from '../../shared/async-state';
import { ToastService } from '../../core/toast/toast.service';

import { Icon } from '../../shared/icon';
import { MAISON } from '../../shared/maison';

@Component({
  selector: 'app-product-page',
  imports: [RouterLink, FormsModule, PageBar, Stars, TranslatePipe, AsyncState, Icon, MAISON],
  templateUrl: './product-page.html',
})
export class ProductPage implements OnInit {
  private readonly api = inject(ApiClient);
  private readonly route = inject(ActivatedRoute);
  readonly auth = inject(AuthService);
  readonly i18n = inject(I18nService);
  private readonly cart = inject(CartService);
  private readonly toast = inject(ToastService);

  product = signal<Product | null>(null);
  reviews = signal<ReviewsPayload>({ items: [] });
  gallery = signal(0);
  loading = signal(true);
  error = signal<string | null>(null);
  adding = signal(false);
  variant = signal<ProductVariant | null>(null);
  qty = 1;
  size = '';
  rating = 5;
  comment = '';

  readonly media = media;
  readonly priceOf = priceOf;
  readonly onSale = onSale;

  ngOnInit(): void {
    this.route.paramMap.subscribe((params) => {
      const id = params.get('id') || '';
      this.load(id);
      this.api.get<ReviewsPayload>('/reviews', { targetType: 'product', targetId: id }).subscribe({
        next: (res) => this.reviews.set(res.data ?? { items: [] }),
        error: () => this.reviews.set({ items: [] }),
      });
    });
  }

  load(id = this.route.snapshot.paramMap.get('id') || ''): void {
    this.loading.set(true);
    this.error.set(null);
    this.gallery.set(0);
    this.qty = 1;
    this.api.get<Product>(`/products/${id}`).subscribe({
      next: (res) => {
        this.product.set(res.data);
        this.size = res.data.sizes?.[0] ?? '';
        const variants = res.data.variants ?? [];
        this.variant.set(variants.find((v) => (v.stock ?? 0) > 0) ?? variants[0] ?? null);
        this.loading.set(false);
      },
      error: (e: Error) => {
        this.product.set(null);
        this.error.set(e.message);
        this.loading.set(false);
      },
    });
  }

  pickVariant(key: string): void {
    const p = this.product();
    this.variant.set(p?.variants?.find((v) => this.variantKey(v) === key) ?? null);
    this.qty = 1;
  }

  variantKey(v: ProductVariant): string {
    return v.name || v.sku || '';
  }

  /** Effective unit price, honouring the selected variant's price. */
  unitPrice(p: Product): number {
    const v = this.variant();
    return v?.price != null ? v.price : priceOf(p);
  }

  showsSale(p: Product): boolean {
    return this.variant()?.price == null && onSale(p);
  }

  stockOf(p: Product): number {
    const v = this.variant();
    return v?.stock != null ? v.stock : (p.stock ?? 0);
  }

  name(p: Product): string {
    return productName(p, this.i18n.lang());
  }

  desc(p: Product): string {
    return productDesc(p, this.i18n.lang());
  }

  images(p: Product): string[] {
    return (p.images ?? []).map(media).filter(Boolean);
  }

  inStock(p: Product): boolean {
    return this.stockOf(p) > 0;
  }

  addToCart(): void {
    const p = this.product();
    if (!p || !this.inStock(p)) return;
    if ((p.sizes?.length ?? 0) > 0 && !this.size) {
      this.toast.show(this.i18n.t('pickSize'));
      return;
    }
    if (this.adding()) return;
    this.adding.set(true);
    const v = this.variant();
    this.cart
      .add(String(p._id || p.id), this.qty, this.size || undefined, v ? this.variantKey(v) : undefined)
      .subscribe({
        next: () => {
          this.adding.set(false);
          this.toast.show(this.i18n.t('added'));
        },
        error: (e) => {
          this.adding.set(false);
          this.toast.show(e.message);
        },
      });
  }

  submitReview(ev: Event): void {
    ev.preventDefault();
    const id = this.route.snapshot.paramMap.get('id') || '';
    this.api
      .post('/reviews', {
        targetType: 'product',
        targetId: id,
        rating: this.rating,
        comment: this.comment,
      })
      .subscribe({
        next: () => {
          this.toast.show(this.i18n.t('thanksRating'));
          this.api.get<ReviewsPayload>('/reviews', { targetType: 'product', targetId: id }).subscribe({
            next: (res) => this.reviews.set(res.data ?? { items: [] }),
          });
        },
        error: (e) => this.toast.show(e.message),
      });
  }

  decQty(): void {
    if (this.qty > 1) this.qty--;
  }

  incQty(): void {
    const p = this.product();
    const max = p ? this.stockOf(p) : 99;
    if (this.qty < max) this.qty++;
  }
}
