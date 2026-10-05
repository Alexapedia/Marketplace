import { Component, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { Product } from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { ProductCard } from '../../shared/product-card';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-shop-page',
  imports: [PageBar, ProductCard, TranslatePipe],
  templateUrl: './shop-page.html',
})
export class ShopPage implements OnInit {
  private readonly api = inject(ApiClient);
  private readonly route = inject(ActivatedRoute);

  products = signal<Product[]>([]);
  q = signal('');

  ngOnInit(): void {
    this.route.queryParamMap.subscribe((params) => {
      this.q.set(params.get('q') || '');
      const query: Record<string, string | number | boolean> = { limit: 40 };
      const category = params.get('category');
      const search = params.get('q');
      if (category) query['categoryId'] = category;
      if (search) query['search'] = search;
      if (params.get('featured')) query['featured'] = true;
      if (params.get('newArrival')) query['newArrival'] = true;
      if (params.get('bestSeller')) query['bestSeller'] = true;
      this.api.get<Product[]>('/products', query).subscribe({
        next: (res) => this.products.set(res.data ?? []),
      });
    });
  }
}
