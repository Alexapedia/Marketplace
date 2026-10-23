import { Component, inject, OnInit, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { Category, flattenCategories, PageMeta, Product } from '../../core/models/models';
import { LocPipe, TranslatePipe } from '../../core/i18n/translate.pipe';
import { AsyncState } from '../../shared/async-state';
import { PageBar } from '../../shared/page-bar';
import { ProductCard } from '../../shared/product-card';

const PAGE_SIZE = 24;

export const SORTS = [
  { value: '', key: 'sortRecommended' },
  { value: '-createdAt', key: 'sortNewest' },
  { value: 'price', key: 'sortPriceAsc' },
  { value: '-price', key: 'sortPriceDesc' },
  { value: '-ratingAvg', key: 'sortRating' },
];

import { Icon } from '../../shared/icon';
import { MAISON } from '../../shared/maison';

@Component({
  selector: 'app-shop-page',
  imports: [FormsModule, PageBar, ProductCard, TranslatePipe, LocPipe, AsyncState, Icon, MAISON],
  templateUrl: './shop-page.html',
})
export class ShopPage implements OnInit {
  /** Presentation only. */
  readonly filtersOpen = signal(false);
  private readonly api = inject(ApiClient);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);

  readonly sorts = SORTS;
  products = signal<Product[]>([]);
  categories = signal<Category[]>([]);
  meta = signal<PageMeta | null>(null);
  loading = signal(true);
  loadingMore = signal(false);
  error = signal<string | null>(null);
  q = signal('');

  // Filter form state (mirrors the URL query params).
  category = '';
  sort = '';
  minPrice: number | null = null;
  maxPrice: number | null = null;
  private flags: Record<string, boolean> = {};

  constructor() {
    this.route.queryParamMap.pipe(takeUntilDestroyed()).subscribe((params) => {
      this.q.set(params.get('q') || '');
      this.category = params.get('category') || '';
      this.sort = params.get('sort') || '';
      this.minPrice = params.get('minPrice') ? Number(params.get('minPrice')) : null;
      this.maxPrice = params.get('maxPrice') ? Number(params.get('maxPrice')) : null;
      this.flags = {};
      for (const f of ['featured', 'newArrival', 'bestSeller']) {
        if (params.get(f)) this.flags[f] = true;
      }
      this.fetch(1);
    });
  }

  ngOnInit(): void {
    this.api.get<Category[]>('/categories').subscribe({
      next: (res) => this.categories.set(flattenCategories(res.data ?? [])),
      error: () => undefined,
    });
  }

  titleKey(): string {
    if (this.flags['featured']) return 'featured';
    if (this.flags['newArrival']) return 'arrivals';
    if (this.flags['bestSeller']) return 'bestsellers';
    return 'allProducts';
  }

  hasMore(): boolean {
    const m = this.meta();
    return !!m && m.page < m.totalPages;
  }

  hasFilters(): boolean {
    return !!(this.category || this.sort || this.minPrice != null || this.maxPrice != null);
  }

  fetch(page: number): void {
    if (page === 1) {
      this.loading.set(true);
      this.error.set(null);
    } else {
      this.loadingMore.set(true);
    }
    const query: Record<string, string | number | boolean> = {
      page,
      limit: PAGE_SIZE,
      ...this.flags,
    };
    if (this.category) query['categoryId'] = this.category;
    if (this.q()) query['search'] = this.q();
    if (this.sort) query['sort'] = this.sort;
    if (this.minPrice != null) query['minPrice'] = this.minPrice;
    if (this.maxPrice != null) query['maxPrice'] = this.maxPrice;
    this.api.get<Product[]>('/products', query).subscribe({
      next: (res) => {
        const items = res.data ?? [];
        this.products.set(page === 1 ? items : [...this.products(), ...items]);
        this.meta.set(res.meta ?? null);
        this.loading.set(false);
        this.loadingMore.set(false);
      },
      error: (e: Error) => {
        if (page === 1) {
          this.products.set([]);
          this.error.set(e.message);
        }
        this.loading.set(false);
        this.loadingMore.set(false);
      },
    });
  }

  loadMore(): void {
    const m = this.meta();
    if (m && !this.loadingMore()) this.fetch(m.page + 1);
  }

  apply(): void {
    void this.router.navigate([], {
      relativeTo: this.route,
      queryParamsHandling: 'merge',
      queryParams: {
        category: this.category || null,
        sort: this.sort || null,
        minPrice: this.minPrice ?? null,
        maxPrice: this.maxPrice ?? null,
      },
    });
  }

  clear(): void {
    this.category = '';
    this.sort = '';
    this.minPrice = null;
    this.maxPrice = null;
    this.apply();
  }
}
