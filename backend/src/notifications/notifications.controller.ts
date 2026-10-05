import { Controller, Get, Param, Patch, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { PaginationDto, paginationMeta } from '../common/dto/pagination.dto';
import type { AuthUser } from '../common/types/auth-user';
import { toObjectId } from '../common/utils/mongo';
import { NotificationsService } from './notifications.service';

@ApiTags('notifications')
@ApiBearerAuth()
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Get()
  async list(@CurrentUser() user: AuthUser, @Query() query: PaginationDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const { items, total } = await this.notifications.findMine(
      user.userId,
      page,
      limit,
    );
    return { data: items, meta: paginationMeta(total, page, limit) };
  }

  @Get('unread-count')
  async unread(@CurrentUser() user: AuthUser) {
    return { count: await this.notifications.unreadCount(user.userId) };
  }

  @Patch(':id/read')
  async markRead(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    toObjectId(id);
    return this.notifications.markRead(user.userId, id);
  }
}
