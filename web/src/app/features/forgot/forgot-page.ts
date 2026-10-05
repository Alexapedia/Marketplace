import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../core/auth/auth.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';
import { AuthLayout } from '../../shared/auth-layout';

@Component({
  selector: 'app-forgot-page',
  imports: [FormsModule, TranslatePipe, AuthLayout],
  templateUrl: './forgot-page.html',
})
export class ForgotPage {
  private readonly auth = inject(AuthService);
  private readonly toast = inject(ToastService);
  readonly i18n = inject(I18nService);

  email = '';
  error = signal('');
  sent = signal(false);
  loading = signal(false);

  submit(ev: Event): void {
    ev.preventDefault();
    if (this.loading()) return;
    this.error.set('');
    this.loading.set(true);
    this.auth.forgotPassword(this.email).subscribe({
      next: () => {
        this.loading.set(false);
        this.sent.set(true);
        this.toast.show(this.i18n.t('forgotSent'));
      },
      error: (e) => {
        this.loading.set(false);
        this.error.set(e.message || this.i18n.t('error'));
      },
    });
  }
}
