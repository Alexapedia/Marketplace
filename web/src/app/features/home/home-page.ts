import { Component, inject, OnInit, signal } from '@angular/core';
import { forkJoin, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ApiClient } from '../../core/api/api-client';
import { AuthService } from '../../core/auth/auth.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { LocPipe, TranslatePipe } from '../../core/i18n/translate.pipe';
import {
  Ad,
  AppPublicConfig,
  Category,
  flattenCategories,
  loc,
  media,
  Product,
  Review,
} from '../../core/models/models';
import { ProductCard } from '../../shared/product-card';
import { Stars } from '../../shared/stars';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-home-page',
  imports: [RouterLink, FormsModule, TranslatePipe, LocPipe, ProductCard, Stars],
  templateUrl: './home-page.html',
})
export class HomePage implements OnInit {
  private readonly api = inject(ApiClient);
  readonly auth = inject(AuthService);
  readonly i18n = inject(I18nService);
  private readonly toast = inject(ToastService);

  categories = signal<Category[]>([]);
  featured = signal<Product[]>([]);
  arrivals = signal<Product[]>([]);
  bestsellers = signal<Product[]>([]);
  highlights = signal<Review[]>([]);
  ads = signal<Ad[]>([]);
  heroAd = signal<Ad | null>(null);
  siteRating = 5;
  siteComment = '';
  readonly media = media;

  ngOnInit(): void {
    forkJoin({
      cats: this.api.get<Category[]>('/categories'),
      feat: this.api.get<Product[]>('/products', { featured: true, limit: 8 }),
      arr: this.api.get<Product[]>('/products', { newArrival: true, limit: 8 }),
      best: this.api.get<Product[]>('/products', { bestSeller: true, limit: 8 }),
      cfg: this.api.get<AppPublicConfig>('/app/config'),
      ads: this.api.get<Ad[]>('/ads', { placement: 'home' }).pipe(catchError(() => of({ data: [] as Ad[] }))),
      revs: this.api
        .get<Review[]>('/reviews/highlights', { limit: 12 })
        .pipe(catchError(() => of({ data: [] as Review[] }))),
    }).subscribe(({ cats, feat, arr, best, ads, revs }) => {
      this.categories.set(cats.data ?? []);
      this.featured.set(feat.data ?? []);
      this.arrivals.set(arr.data ?? []);
      this.bestsellers.set(best.data ?? []);
      const adList = ads.data?.length ? ads.data : [];
      this.ads.set(adList);
      this.heroAd.set(adList.find((a) => a.active !== false) ?? null);
      this.highlights.set(revs.data ?? []);
    });
  }

  flatCats(): Category[] {
    return flattenCategories(this.categories());
  }

  heroTitle(): string {
    const ad = this.heroAd();
    if (ad?.title) return loc(ad.title, this.i18n.lang()) || this.i18n.t('heroTitle');
    return this.i18n.t('heroTitle');
  }

  heroBody(): string {
    const ad = this.heroAd();
    if (ad?.subtitle) return loc(ad.subtitle, this.i18n.lang()) || this.i18n.t('heroBody');
    return this.i18n.t('heroBody');
  }

  heroImage(): string {
    return media(this.heroAd()?.image);
  }

  adRoute(ad: Ad): {
    path: string | string[];
    query: Record<string, string> | null;
    external: boolean;
  } {
    if (ad.productId) {
      const id =
        typeof ad.productId === 'string'
          ? ad.productId
          : String((ad.productId as Product)._id || (ad.productId as Product).id || '');
      return { path: ['/product', id], query: null, external: false };
    }
    if (ad.categoryId) {
      const id =
        typeof ad.categoryId === 'string'
          ? ad.categoryId
          : String((ad.categoryId as Category)._id || (ad.categoryId as Category).id || '');
      return { path: '/shop', query: { category: id }, external: false };
    }
    if (ad.link?.startsWith('http')) {
      return { path: ad.link, query: null, external: true };
    }
    return { path: ad.link || '/shop', query: null, external: false };
  }

  submitSiteRating(ev: Event): void {
    ev.preventDefault();
    this.api
      .post('/reviews', {
        targetType: 'website',
        rating: this.siteRating,
        comment: this.siteComment,
      })
      .subscribe({
        next: () => {
          this.toast.show(this.i18n.t('thanksRating'));
          this.siteComment = '';
        },
        error: (e) => this.toast.show(e.message),
      });
  }
}
