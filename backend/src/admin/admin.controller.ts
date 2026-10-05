import {
  Body,
  Controller,
  Delete,
  Get,
  NotFoundException,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UploadedFiles,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { Request } from 'express';
import { AppConfigService } from '../app-config/app-config.service';
import { CategoriesService } from '../catalog/categories.service';
import { CustomFieldsService } from '../catalog/custom-fields.service';
import {
  CreateCategoryDto,
  CreateCustomFieldDto,
  CreateProductDto,
  UpdateCategoryDto,
  UpdateCustomFieldDto,
  UpdateProductDto,
} from '../catalog/dto/catalog.dto';
import { ProductsService } from '../catalog/products.service';
import { STAFF_ROLES } from '../common/constants';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Permissions } from '../common/decorators/permissions.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { PaginationDto } from '../common/dto/pagination.dto';
import type { AuthUser } from '../common/types/auth-user';
import { CustomOrdersService } from '../custom-orders/custom-orders.service';
import {
  AdminUpdateCustomOrderDto,
  CreateMessageDto,
  CreateProposalDto,
} from '../custom-orders/dto/custom-order.dto';
import { NotificationsService } from '../notifications/notifications.service';
import {
  AdminUpdateOrderDto,
  ChangeOrderStatusDto,
} from '../orders/dto/order.dto';
import { OrdersService } from '../orders/orders.service';
import {
  AdminListReviewsQuery,
  PatchReviewDto,
} from '../reviews/dto/review.dto';
import { ReviewsService } from '../reviews/reviews.service';
import { UploadsService } from '../uploads/uploads.service';
import { AdminService } from './admin.service';
import {
  AdminListQuery,
  CreateStaffDto,
  PatchAppConfigDto,
  PatchCustomerDto,
  PatchStaffDto,
  ReportsQueryDto,
  SendNotificationDto,
  UpdateRoleDto,
} from './dto/admin.dto';

@ApiTags('admin')
@ApiBearerAuth()
@Roles(...STAFF_ROLES)
@Controller('admin')
export class AdminController {
  constructor(
    private readonly admin: AdminService,
    private readonly products: ProductsService,
    private readonly categories: CategoriesService,
    private readonly customFields: CustomFieldsService,
    private readonly orders: OrdersService,
    private readonly customOrders: CustomOrdersService,
    private readonly notifications: NotificationsService,
    private readonly appConfig: AppConfigService,
    private readonly reviews: ReviewsService,
    private readonly uploads: UploadsService,
  ) {}

  @Get('dashboard')
  @Permissions('dashboard.read')
  dashboard() {
    return this.admin.dashboard();
  }

  @Get('products')
  @Permissions('products.read')
  listProducts(@Query() query: AdminListQuery) {
    return this.products.listAdmin(query);
  }

  @Post('products')
  @Permissions('products.write')
  createProduct(@Body() dto: CreateProductDto) {
    return this.products.create(dto);
  }

  @Get('products/:id')
  @Permissions('products.read')
  getProduct(@Param('id') id: string) {
    return this.products.findAdmin(id);
  }

  @Patch('products/:id')
  @Permissions('products.write')
  updateProduct(@Param('id') id: string, @Body() dto: UpdateProductDto) {
    return this.products.update(id, dto);
  }

  @Delete('products/:id')
  @Permissions('products.write')
  deleteProduct(@Param('id') id: string) {
    return this.products.remove(id);
  }

  @Get('categories')
  @Permissions('categories.read')
  listCategories() {
    return this.categories.listAdmin();
  }

  @Post('categories')
  @Permissions('categories.write')
  createCategory(@Body() dto: CreateCategoryDto) {
    return this.categories.create(dto);
  }

  @Get('categories/:id')
  @Permissions('categories.read')
  getCategory(@Param('id') id: string) {
    return this.categories.findAdmin(id);
  }

  @Patch('categories/:id')
  @Permissions('categories.write')
  updateCategory(@Param('id') id: string, @Body() dto: UpdateCategoryDto) {
    return this.categories.update(id, dto);
  }

  @Delete('categories/:id')
  @Permissions('categories.write')
  deleteCategory(@Param('id') id: string) {
    return this.categories.remove(id);
  }

  @Get('custom-fields')
  @Permissions('custom-fields.read')
  listFields(@Query('categoryId') categoryId?: string) {
    return this.customFields.listAdmin(categoryId);
  }

  @Post('custom-fields')
  @Permissions('custom-fields.write')
  createField(@Body() dto: CreateCustomFieldDto) {
    return this.customFields.create(dto);
  }

  @Get('custom-fields/:id')
  @Permissions('custom-fields.read')
  getField(@Param('id') id: string) {
    return this.customFields.findAdmin(id);
  }

  @Patch('custom-fields/:id')
  @Permissions('custom-fields.write')
  updateField(@Param('id') id: string, @Body() dto: UpdateCustomFieldDto) {
    return this.customFields.update(id, dto);
  }

  @Delete('custom-fields/:id')
  @Permissions('custom-fields.write')
  deleteField(@Param('id') id: string) {
    return this.customFields.remove(id);
  }

  @Get('orders')
  @Permissions('orders.read')
  listOrders(@Query() query: AdminListQuery) {
    return this.orders.listAdmin(query);
  }

  @Get('orders/:id')
  @Permissions('orders.read')
  getOrder(@Param('id') id: string) {
    return this.orders.findAdmin(id);
  }

  @Patch('orders/:id')
  @Permissions('orders.write')
  patchOrder(@Param('id') id: string, @Body() dto: AdminUpdateOrderDto) {
    return this.orders.updateAdmin(id, dto);
  }

  @Patch('orders/:id/status')
  @Permissions('orders.write')
  orderStatus(
    @Param('id') id: string,
    @Body() dto: ChangeOrderStatusDto,
    @CurrentUser() user: AuthUser,
    @Req() req: Request,
  ) {
    return this.orders.changeStatus(id, dto, user.userId, req.ip);
  }

  @Get('custom-orders')
  @Permissions('custom-orders.read')
  listCustom(@Query() query: AdminListQuery) {
    return this.customOrders.listAdmin(query);
  }

  @Get('custom-orders/:id')
  @Permissions('custom-orders.read')
  getCustom(@Param('id') id: string) {
    return this.customOrders.findAdmin(id);
  }

  @Patch('custom-orders/:id')
  @Permissions('custom-orders.write')
  patchCustom(
    @Param('id') id: string,
    @Body() dto: AdminUpdateCustomOrderDto,
  ) {
    return this.customOrders.updateAdmin(id, dto);
  }

  @Post('custom-orders/:id/proposals')
  @Permissions('custom-orders.write')
  sendProposal(
    @Param('id') id: string,
    @Body() dto: CreateProposalDto,
    @CurrentUser() user: AuthUser,
  ) {
    return this.customOrders.sendProposal(id, dto, user.userId);
  }

  @Get('customers')
  @Permissions('customers.read')
  customers(@Query() query: AdminListQuery) {
    return this.admin.customers(
      query.page ?? 1,
      query.limit ?? 20,
      query.search,
      query.status,
    );
  }

  @Get('customers/:id')
  @Permissions('customers.read')
  async getCustomer(@Param('id') id: string) {
    const user = await this.admin.findCustomer(id);
    if (!user) {
      throw new NotFoundException('Customer not found');
    }
    return user;
  }

  @Patch('customers/:id')
  @Permissions('customers.write')
  async patchCustomer(@Param('id') id: string, @Body() dto: PatchCustomerDto) {
    const user = await this.admin.patchCustomer(id, dto.status);
    if (!user) {
      throw new NotFoundException('Customer not found');
    }
    return user;
  }

  @Get('staff')
  @Roles('super_admin', 'admin')
  @Permissions('customers.read')
  listStaff(@Query() query: AdminListQuery) {
    return this.admin.listStaff(
      query.page ?? 1,
      query.limit ?? 20,
      query.search,
      query.role,
    );
  }

  @Post('staff')
  @Roles('super_admin', 'admin')
  @Permissions('customers.write')
  createStaff(@Body() dto: CreateStaffDto) {
    return this.admin.createStaff(dto);
  }

  @Patch('staff/:id')
  @Roles('super_admin', 'admin')
  @Permissions('customers.write')
  patchStaff(@Param('id') id: string, @Body() dto: PatchStaffDto) {
    return this.admin.patchStaff(id, dto);
  }

  @Get('chats')
  @Permissions('chats.read')
  chats(
    @Query() query: PaginationDto,
    @Query('customOrderId') customOrderId?: string,
  ) {
    return this.customOrders.listChats(
      query.page ?? 1,
      query.limit ?? 20,
      customOrderId,
    );
  }

  @Get('chats/:id/messages')
  @Permissions('chats.read')
  chatMessages(@Param('id') id: string) {
    return this.customOrders.listChatMessages(id);
  }

  @Post('chats/:id/messages')
  @Permissions('chats.write')
  @UseInterceptors(FilesInterceptor('files', 8))
  postChat(
    @Param('id') id: string,
    @Body() dto: CreateMessageDto,
    @CurrentUser() user: AuthUser,
    @UploadedFiles() files?: Express.Multer.File[],
  ) {
    const urls = (files ?? []).map((f) => this.uploads.toUrl(f.filename));
    return this.customOrders.postChatMessage(user, id, dto, urls);
  }

  @Get('notifications/unread-count')
  async unreadCount(@CurrentUser() user: AuthUser) {
    const count = await this.notifications.unreadCount(user.userId);
    return { count };
  }

  @Get('notifications')
  @Permissions('notifications.write')
  listNotifications(@Query() query: PaginationDto) {
    return this.notifications.listAdmin(query.page ?? 1, query.limit ?? 20);
  }

  @Post('notifications')
  @Permissions('notifications.write')
  sendNotification(@Body() dto: SendNotificationDto) {
    return this.notifications.sendToTargets(dto);
  }

  @Get('app-config')
  @Permissions('app-config.read')
  getConfig() {
    return this.appConfig.getGlobal();
  }

  @Patch('app-config')
  @Permissions('app-config.write')
  patchConfig(@Body() dto: PatchAppConfigDto) {
    return this.appConfig.update(dto as Record<string, unknown>);
  }

  @Get('reports')
  @Permissions('reports.read')
  reports(@Query() query: ReportsQueryDto) {
    return this.admin.reports(query.from, query.to);
  }

  @Get('reviews')
  @Permissions('reviews.read')
  listReviews(@Query() query: AdminListReviewsQuery) {
    return this.reviews.listAdmin(query);
  }

  @Patch('reviews/:id')
  @Permissions('reviews.write')
  patchReview(@Param('id') id: string, @Body() dto: PatchReviewDto) {
    return this.reviews.patch(id, dto.hidden);
  }

  @Delete('reviews/:id')
  @Permissions('reviews.write')
  deleteReview(@Param('id') id: string) {
    return this.reviews.remove(id);
  }

  @Get('audit-logs')
  @Permissions('audit-logs.read')
  auditLogs(@Query() query: AdminListQuery) {
    return this.admin.auditLogs(
      query.page ?? 1,
      query.limit ?? 20,
      query.search,
    );
  }

  @Get('roles')
  @Permissions('roles.read')
  roles() {
    return this.admin.roles();
  }

  @Patch('roles/:id')
  @Permissions('roles.write')
  async patchRole(@Param('id') id: string, @Body() dto: UpdateRoleDto) {
    const role = await this.admin.updateRole(id, dto.permissions ?? []);
    if (!role) {
      throw new NotFoundException('Role not found');
    }
    return role;
  }
}
