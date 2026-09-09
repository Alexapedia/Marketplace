import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UploadedFiles,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiConsumes, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { PaginationDto } from '../common/dto/pagination.dto';
import type { AuthUser } from '../common/types/auth-user';
import { UploadsService } from '../uploads/uploads.service';
import {
  ConfirmProposalDto,
  CreateCustomOrderDto,
  CreateMessageDto,
  RejectProposalDto,
} from './dto/custom-order.dto';
import { CustomOrdersService } from './custom-orders.service';

@ApiTags('custom-orders')
@ApiBearerAuth()
@Controller('custom-orders')
export class CustomOrdersController {
  constructor(
    private readonly customOrders: CustomOrdersService,
    private readonly uploads: UploadsService,
  ) {}

  @Post()
  @ApiConsumes('multipart/form-data', 'application/json')
  @UseInterceptors(FilesInterceptor('attachments', 8))
  create(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateCustomOrderDto,
    @UploadedFiles() files?: Express.Multer.File[],
  ) {
    const urls = (files ?? []).map((f) => this.uploads.toUrl(f.filename));
    return this.customOrders.create(user.userId, dto, urls);
  }

  @Get()
  list(@CurrentUser() user: AuthUser, @Query() query: PaginationDto) {
    return this.customOrders.listMine(
      user.userId,
      query.page ?? 1,
      query.limit ?? 20,
    );
  }

  @Get(':id')
  get(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.customOrders.findMine(user.userId, id);
  }

  @Post(':id/confirm')
  confirm(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: ConfirmProposalDto,
  ) {
    return this.customOrders.confirm(user.userId, id, dto);
  }

  @Post(':id/reject')
  reject(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: RejectProposalDto,
  ) {
    return this.customOrders.reject(user.userId, id, dto);
  }

  @Get(':id/messages')
  messages(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.customOrders.listMessages(user, id);
  }

  @Post(':id/messages')
  @ApiConsumes('multipart/form-data', 'application/json')
  @UseInterceptors(FilesInterceptor('files', 8))
  postMessage(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: CreateMessageDto,
    @UploadedFiles() files?: Express.Multer.File[],
  ) {
    if (!dto.text && !files?.length) {
      throw new BadRequestException('text or files required');
    }
    const urls = (files ?? []).map((f) => this.uploads.toUrl(f.filename));
    return this.customOrders.postMessage(user, id, dto, urls);
  }
}
