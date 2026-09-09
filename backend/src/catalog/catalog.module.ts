import { Module } from '@nestjs/common';
import { CatalogController } from './catalog.controller';
import { CategoriesService } from './categories.service';
import { CustomFieldsService } from './custom-fields.service';
import { ProductsService } from './products.service';

@Module({
  controllers: [CatalogController],
  providers: [CategoriesService, ProductsService, CustomFieldsService],
  exports: [CategoriesService, ProductsService, CustomFieldsService],
})
export class CatalogModule {}
