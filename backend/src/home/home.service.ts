import { Injectable } from '@nestjs/common';
import { AdsService } from '../ads/ads.service';
import { AppConfigService } from '../app-config/app-config.service';
import { CategoriesService } from '../catalog/categories.service';
import { ProductsService } from '../catalog/products.service';
import { ReviewsService } from '../reviews/reviews.service';

@Injectable()
export class HomeService {
  constructor(
    private readonly config: AppConfigService,
    private readonly ads: AdsService,
    private readonly categories: CategoriesService,
    private readonly products: ProductsService,
    private readonly reviews: ReviewsService,
  ) {}

  async feed() {
    const [config, ads, categories, featured, newArrival, bestSeller, highlights] =
      await Promise.all([
        this.config.getPublic(),
        this.ads.listPublic('home'),
        this.categories.listPublic(),
        this.products.listPublic({ featured: true, limit: 10 }),
        this.products.listPublic({ newArrival: true, limit: 10 }),
        this.products.listPublic({ bestSeller: true, limit: 10 }),
        this.reviews.highlights(8),
      ]);
    return {
      config,
      ads,
      categories,
      featured: featured.data,
      newArrivals: newArrival.data,
      bestSellers: bestSeller.data,
      highlights,
    };
  }
}
