import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { NotificationsApi } from '../../core/api/notifications.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { loc, AppNotification } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-notifications-page',
  imports: [
    DatePipe,
    ReactiveFormsModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    TranslatePipe,
    AsyncState,
  ],
  templateUrl: './notifications-page.html',
  styleUrl: './notifications-page.scss',
})
export class NotificationsPage implements OnInit {
  private readonly api = inject(NotificationsApi);
  private readonly fb = inject(FormBuilder);
  private readonly ui = inject(UiService);
  private readonly router = inject(Router);
  readonly i18n = inject(I18nService);

  readonly sending = signal(false);
  readonly historyLoading = signal(false);
  readonly historyError = signal<string | null>(null);
  readonly history = signal<AppNotification[]>([]);
  readonly inboxLoading = signal(false);
  readonly inboxError = signal<string | null>(null);
  readonly inbox = signal<AppNotification[]>([]);

  readonly form = this.fb.nonNullable.group({
    titleEn: ['', Validators.required],
    titleAr: ['', Validators.required],
    bodyEn: ['', Validators.required],
    bodyAr: ['', Validators.required],
    target: ['all' as 'all' | 'userIds'],
    userIds: [''],
  });

  ngOnInit(): void {
    this.loadInbox();
    this.loadHistory();
  }

  loadInbox(): void {
    this.inboxLoading.set(true);
    this.inboxError.set(null);
    this.api.inbox({ limit: 40 }).subscribe({
      next: (res) => {
        this.inbox.set(asList(res.data));
        this.inboxLoading.set(false);
      },
      error: (err: unknown) => {
        this.inboxLoading.set(false);
        this.inboxError.set(errMessage(err));
      },
    });
  }

  loadHistory(): void {
    this.historyLoading.set(true);
    this.historyError.set(null);
    this.api.history({ limit: 50 }).subscribe({
      next: (res) => {
        this.history.set(asList(res.data));
        this.historyLoading.set(false);
      },
      error: () => {
        this.historyLoading.set(false);
        this.historyError.set(null);
      },
    });
  }

  titleOf(item: AppNotification): string {
    return loc(item.title, this.i18n.lang()) || item.type || '';
  }

  bodyOf(item: AppNotification): string {
    return loc(item.body, this.i18n.lang());
  }

  openItem(item: AppNotification): void {
    const id = item._id ?? item.id ?? '';
    if (id) {
      this.api.markRead(id).subscribe({ next: () => this.loadInbox() });
    }
    if (item.type === 'new_custom_order') {
      void this.router.navigate(['/custom-orders']);
      return;
    }
    if (item.type === 'new_order' || item.data?.['orderId']) {
      void this.router.navigate(['/orders']);
    }
  }

  send(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    const v = this.form.getRawValue();
    const userIds = v.userIds
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);
    this.sending.set(true);
    this.api
      .send({
        title: { en: v.titleEn, ar: v.titleAr },
        body: { en: v.bodyEn, ar: v.bodyAr },
        target: v.target,
        userIds: v.target === 'userIds' ? userIds : undefined,
      })
      .subscribe({
        next: () => {
          this.sending.set(false);
          this.ui.success(this.i18n.t('notifications.sent'));
          this.form.reset({
            titleEn: '',
            titleAr: '',
            bodyEn: '',
            bodyAr: '',
            target: 'all',
            userIds: '',
          });
          this.loadHistory();
        },
        error: (err: unknown) => {
          this.sending.set(false);
          this.ui.error(errMessage(err));
        },
      });
  }
}
