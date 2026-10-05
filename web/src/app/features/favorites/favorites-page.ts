import { Component, inject, OnInit, signal } from '@angular/core';
import { ApiClient } from '../../core/api/api-client';
import { Favorite, pid, Product } from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { ProductCard } from '../../shared/product-card';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-favorites-page',
  imports: [PageBar, ProductCard, TranslatePipe],
  templateUrl: './favorites-page.html',
})
export class FavoritesPage implements OnInit {
  private readonly api = inject(ApiClient);
  products = signal<Product[]>([]);
  favoriteIds = signal<Set<string>>(new Set());

  ngOnInit(): void {
    this.api.get<Favorite[]>('/favorites').subscribe({
      next: (res) => {
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
