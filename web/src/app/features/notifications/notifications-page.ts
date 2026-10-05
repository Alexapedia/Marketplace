import { Component, inject, OnInit, signal } from '@angular/core';
import { ApiClient } from '../../core/api/api-client';
import { I18nService } from '../../core/i18n/i18n.service';
import { asItems, loc, NotificationItem } from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-notifications-page',
  imports: [PageBar, TranslatePipe],
  templateUrl: './notifications-page.html',
})
export class NotificationsPage implements OnInit {
  private readonly api = inject(ApiClient);
  readonly i18n = inject(I18nService);
  items = signal<NotificationItem[]>([]);

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.api.get<NotificationItem[]>('/notifications').subscribe({
      next: (res) => this.items.set(asItems<NotificationItem>(res.data)),
    });
  }

  title(n: NotificationItem): string {
    return loc(n.title, this.i18n.lang());
  }

  body(n: NotificationItem): string {
    return loc(n.body, this.i18n.lang());
  }

  markRead(n: NotificationItem): void {
    const id = String(n._id || n.id || '');
    if (!id || n.readAt) return;
    this.api.patch(`/notifications/${id}/read`, {}).subscribe({ next: () => this.load() });
  }
}
