import { Module } from '@nestjs/common';
import { AdsModule } from '../ads/ads.module';
import { AppConfigModule } from '../app-config/app-config.module';
import { CatalogModule } from '../catalog/catalog.module';
import { ReviewsModule } from '../reviews/reviews.module';
import { HomeController } from './home.controller';
import { HomeService } from './home.service';

@Module({
  imports: [AppConfigModule, AdsModule, CatalogModule, ReviewsModule],
  controllers: [HomeController],
  providers: [HomeService],
})
export class HomeModule {}
