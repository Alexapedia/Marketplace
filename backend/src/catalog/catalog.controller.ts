import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { IsBooleanString, IsMongoId, IsOptional, IsString } from 'class-validator';
import { Public } from '../common/decorators/public.decorator';
import { PaginationDto } from '../common/dto/pagination.dto';
import { CategoriesService } from './categories.service';
import { CustomFieldsService } from './custom-fields.service';
import { ProductsService } from './products.service';

class ProductListQuery extends PaginationDto {
  @IsOptional()
  @IsMongoId()
  categoryId?: string;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @IsBooleanString()
  featured?: string;

  @IsOptional()
  @IsBooleanString()
  newArrival?: string;

  @IsOptional()
  @IsBooleanString()
  bestSeller?: string;

  @IsOptional()
  @IsString()
  gender?: string;

  @IsOptional()
  @IsString()
  sort?: string;
}

class CustomFieldQuery {
  @IsOptional()
  @IsMongoId()
  categoryId?: string;
}

@ApiTags('catalog')
@Controller()
export class CatalogController {
  constructor(
    private readonly categories: CategoriesService,
    private readonly products: ProductsService,
    private readonly customFields: CustomFieldsService,
  ) {}

  @Public()
  @Get('categories')
  listCategories() {
    return this.categories.listPublic();
  }

  @Public()
  @Get('categories/:id')
  getCategory(@Param('id') id: string) {
    return this.categories.findPublic(id);
  }

  @Public()
  @Get('products')
  listProducts(@Query() query: ProductListQuery) {
    return this.products.listPublic(query);
  }

  @Public()
  @Get('products/:id')
  getProduct(@Param('id') id: string) {
    return this.products.findPublic(id);
  }

  @Public()
  @Get('custom-fields')
  listFields(@Query() query: CustomFieldQuery) {
    return this.customFields.listPublic(query.categoryId);
  }
}
