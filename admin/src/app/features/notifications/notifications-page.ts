import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { NotificationsApi } from '../../core/api/notifications.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { LocPipe, TranslatePipe } from '../../core/i18n/translate.pipe';
import { AppNotification } from '../../core/models/models';
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
    MatTableModule,
    TranslatePipe,
    LocPipe,
    AsyncState,
  ],
  templateUrl: './notifications-page.html',
  styleUrl: './notifications-page.scss',
})
export class NotificationsPage implements OnInit {
  private readonly api = inject(NotificationsApi);
  private readonly fb = inject(FormBuilder);
  private readonly ui = inject(UiService);
  readonly i18n = inject(I18nService);

  readonly sending = signal(false);
  readonly historyLoading = signal(false);
  readonly historyError = signal<string | null>(null);
  readonly history = signal<AppNotification[]>([]);
  readonly showHistory = signal(false);
  readonly cols = ['title', 'createdAt'];

  readonly form = this.fb.nonNullable.group({
    titleEn: ['', Validators.required],
    titleAr: ['', Validators.required],
    bodyEn: ['', Validators.required],
    bodyAr: ['', Validators.required],
    target: ['all' as 'all' | 'userIds'],
    userIds: [''],
  });

  ngOnInit(): void {
    this.loadHistory();
  }

  loadHistory(): void {
    this.historyLoading.set(true);
    this.historyError.set(null);
    this.api.history({ limit: 50 }).subscribe({
      next: (res) => {
        this.history.set(asList(res.data));
        this.showHistory.set(true);
        this.historyLoading.set(false);
      },
      error: () => {
        this.showHistory.set(false);
        this.historyLoading.set(false);
        this.historyError.set(null);
      },
    });
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
          this.loadHistory();
        },
        error: (err: unknown) => {
          this.sending.set(false);
          this.ui.error(errMessage(err));
        },
      });
  }
}
