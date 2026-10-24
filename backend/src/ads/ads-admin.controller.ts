import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Permissions } from '../common/decorators/permissions.decorator';
import { PaginationDto } from '../common/dto/pagination.dto';
import { AdsService } from './ads.service';
import { UpsertAdDto } from './dto/ad.dto';

@ApiTags('admin-ads')
@ApiBearerAuth()
@Controller('admin/ads')
export class AdsAdminController {
  constructor(private readonly ads: AdsService) {}

  @Get()
  @Permissions('ads.read')
  list(@Query() query: PaginationDto & { placement?: string; search?: string; active?: string }) {
    return this.ads.listAdmin(query.page ?? 1, query.limit ?? 20, query);
  }

  @Get(':id')
  @Permissions('ads.read')
  get(@Param('id') id: string) {
    return this.ads.get(id);
  }

  @Post()
  @Permissions('ads.write')
  create(@Body() dto: UpsertAdDto) {
    return this.ads.create(dto);
  }

  @Patch(':id')
  @Permissions('ads.write')
  update(@Param('id') id: string, @Body() dto: UpsertAdDto) {
    return this.ads.update(id, dto);
  }

  @Delete(':id')
  @Permissions('ads.write')
  remove(@Param('id') id: string) {
    return this.ads.remove(id);
  }
}
