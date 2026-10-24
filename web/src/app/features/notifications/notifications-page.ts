import { DatePipe } from '@angular/common';
import { Component, inject, OnInit } from '@angular/core';
import { ApiClient } from '../../core/api/api-client';
import { PagedList } from '../../core/api/paged-list';
import { I18nService } from '../../core/i18n/i18n.service';
import { loc, NotificationItem } from '../../core/models/models';
import { ToastService } from '../../core/toast/toast.service';
import { AsyncState } from '../../shared/async-state';
import { LoadMore } from '../../shared/load-more';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

import { Icon } from '../../shared/icon';
import { MAISON } from '../../shared/maison';

@Component({
  selector: 'app-notifications-page',
  imports: [DatePipe, PageBar, TranslatePipe, AsyncState, LoadMore, Icon, MAISON],
  templateUrl: './notifications-page.html',
})
export class NotificationsPage implements OnInit {
  private readonly api = inject(ApiClient);
  private readonly toast = inject(ToastService);
  readonly i18n = inject(I18nService);
  readonly list = new PagedList<NotificationItem>(this.api, '/notifications');

  ngOnInit(): void {
    this.list.reload();
  }

  idOf(n: NotificationItem): string {
    return String(n._id || n.id || '');
  }

  title(n: NotificationItem): string {
    return loc(n.title, this.i18n.lang());
  }

  body(n: NotificationItem): string {
    return loc(n.body, this.i18n.lang());
  }

  hasUnread(): boolean {
    return this.list.items().some((n) => !n.readAt);
  }

  markRead(n: NotificationItem): void {
    const id = this.idOf(n);
    if (!id || n.readAt) return;
    this.api.patch(`/notifications/${id}/read`, {}).subscribe({
      next: () =>
        this.list.update((items) =>
          items.map((x) => (this.idOf(x) === id ? { ...x, readAt: new Date().toISOString() } : x)),
        ),
      error: (e: Error) => this.toast.show(e.message),
    });
  }

  markAllRead(): void {
    this.api.patch('/notifications/read-all', {}).subscribe({
      next: () => {
        const now = new Date().toISOString();
        this.list.update((items) => items.map((x) => (x.readAt ? x : { ...x, readAt: now })));
      },
      error: (e: Error) => this.toast.show(e.message),
    });
  }

  remove(n: NotificationItem): void {
    const id = this.idOf(n);
    this.api.delete(`/notifications/${id}`).subscribe({
      next: () => this.list.update((items) => items.filter((x) => this.idOf(x) !== id)),
      error: (e: Error) => this.toast.show(e.message),
    });
  }
}
