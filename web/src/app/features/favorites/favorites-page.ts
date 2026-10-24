import { Component, inject, OnInit, signal } from '@angular/core';
import { ApiClient } from '../../core/api/api-client';
import { Favorite, pid, Product } from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { ProductCard } from '../../shared/product-card';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { AsyncState } from '../../shared/async-state';

import { MAISON } from '../../shared/maison';

@Component({
  selector: 'app-favorites-page',
  imports: [PageBar, ProductCard, TranslatePipe, AsyncState, MAISON],
  templateUrl: './favorites-page.html',
})
export class FavoritesPage implements OnInit {
  private readonly api = inject(ApiClient);
  products = signal<Product[]>([]);
  favoriteIds = signal<Set<string>>(new Set());
  loading = signal(true);
  error = signal<string | null>(null);

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.get<Favorite[]>('/favorites').subscribe({
      error: (e: Error) => {
        this.error.set(e.message);
        this.loading.set(false);
      },
      next: (res) => {
        this.loading.set(false);
        const rows = Array.isArray(res.data) ? res.data : [];
        const products = rows
          .map((row) => (row.productId && typeof row.productId === 'object' ? row.productId : null))
          .filter((p): p is Product => Boolean(p));
        this.products.set(products);
        this.favoriteIds.set(new Set(products.map(pid).filter(Boolean)));
      },
    });
  }

  isLiked(p: Product): boolean {
    return this.favoriteIds().has(pid(p));
  }
}
