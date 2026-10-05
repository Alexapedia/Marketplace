import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { AuthService } from '../../core/auth/auth.service';
import { media } from '../../core/models/models';
import { I18nService } from '../../core/i18n/i18n.service';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-account-edit-page',
  imports: [FormsModule, PageBar, TranslatePipe],
  templateUrl: './account-edit-page.html',
})
export class AccountEditPage {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiClient);
  private readonly router = inject(Router);
  private readonly toast = inject(ToastService);
  private readonly i18n = inject(I18nService);

  name = this.auth.user()?.name || '';
  phone = this.auth.user()?.phone || '';
  error = signal('');
  readonly media = media;

  submit(ev: Event): void {
    ev.preventDefault();
    this.auth.updateMe({ name: this.name, phone: this.phone }).subscribe({
      next: () => {
        this.toast.show(this.i18n.t('profileUpdated'));
        void this.router.navigate(['/account']);
      },
      error: (e) => this.error.set(e.message),
    });
  }

  onAvatar(ev: Event): void {
    const input = ev.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    this.api.upload(file).subscribe({
      next: (res) => {
        this.auth.updateMe({ avatar: res.data.url }).subscribe({
          next: () => this.toast.show(this.i18n.t('profileUpdated')),
          error: (e) => this.error.set(e.message),
        });
      },
      error: (e) => this.error.set(e.message),
    });
  }
}
