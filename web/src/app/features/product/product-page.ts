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
  productDesc,
  productName,
  Review,
  ReviewsPayload,
} from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { Stars } from '../../shared/stars';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-product-page',
  imports: [RouterLink, FormsModule, PageBar, Stars, TranslatePipe],
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
      this.api.get<Product>(`/products/${id}`).subscribe({
        next: (res) => {
          this.product.set(res.data);
          const sizes = res.data.sizes ?? [];
          this.size = sizes[0] ?? '';
        },
      });
      this.api.get<ReviewsPayload>('/reviews', { targetType: 'product', targetId: id }).subscribe({
        next: (res) => this.reviews.set(res.data ?? { items: [] }),
        error: () => this.reviews.set({ items: [] }),
      });
    });
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
    return (p.stock ?? 0) > 0;
  }

  addToCart(): void {
    const p = this.product();
    if (!p || !this.inStock(p)) return;
    if ((p.sizes?.length ?? 0) > 0 && !this.size) {
      this.toast.show(this.i18n.t('pickSize'));
      return;
    }
    this.cart.add(String(p._id || p.id), this.qty, this.size || undefined).subscribe({
      next: () => this.toast.show(this.i18n.t('added')),
      error: (e) => this.toast.show(e.message),
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
    const max = this.product()?.stock ?? 99;
    if (this.qty < max) this.qty++;
  }
}
