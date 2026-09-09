import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
} from '@nestjs/common';
import { ApiBearerAuth, ApiProperty, ApiTags } from '@nestjs/swagger';
import { IsMongoId } from 'class-validator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { AuthUser } from '../common/types/auth-user';
import { FavoritesService } from './favorites.service';

class AddFavoriteDto {
  @ApiProperty()
  @IsMongoId()
  productId: string;
}

@ApiTags('favorites')
@ApiBearerAuth()
@Controller('favorites')
export class FavoritesController {
  constructor(private readonly favorites: FavoritesService) {}

  @Get()
  list(@CurrentUser() user: AuthUser) {
    return this.favorites.list(user.userId);
  }

  @Post()
  add(@CurrentUser() user: AuthUser, @Body() dto: AddFavoriteDto) {
    return this.favorites.add(user.userId, dto.productId);
  }

  @Delete(':productId')
  remove(@CurrentUser() user: AuthUser, @Param('productId') productId: string) {
    return this.favorites.remove(user.userId, productId);
  }
}
