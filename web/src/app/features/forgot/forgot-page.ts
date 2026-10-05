import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../core/auth/auth.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-forgot-page',
  imports: [FormsModule, RouterLink, TranslatePipe],
  templateUrl: './forgot-page.html',
})
export class ForgotPage {
  private readonly auth = inject(AuthService);
  private readonly toast = inject(ToastService);
  private readonly i18n = inject(I18nService);

  email = '';
  error = signal('');
  sent = signal(false);

  submit(ev: Event): void {
    ev.preventDefault();
    this.error.set('');
    this.auth.forgotPassword(this.email).subscribe({
      next: () => {
        this.sent.set(true);
        this.toast.show(this.i18n.t('forgotSent'));
      },
      error: (e) => this.error.set(e.message),
    });
  }
}
