import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../core/auth/auth.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';
import { AuthEye } from '../../shared/auth-eye';
import { AuthLayout } from '../../shared/auth-layout';

@Component({
  selector: 'app-reset-page',
  imports: [FormsModule, TranslatePipe, AuthLayout, AuthEye],
  templateUrl: './reset-page.html',
})
export class ResetPage {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly toast = inject(ToastService);
  readonly i18n = inject(I18nService);

  token = this.route.snapshot.queryParamMap.get('token') || '';
  password = '';
  error = signal('');
  loading = signal(false);
  hide = signal(true);

  submit(ev: Event): void {
    ev.preventDefault();
    if (this.loading()) return;
    this.error.set('');
    this.loading.set(true);
    this.auth.resetPassword(this.token, this.password).subscribe({
      next: () => {
        this.toast.show(this.i18n.t('resetDone'));
        void this.router.navigate(['/login']);
      },
      error: (e) => {
        this.loading.set(false);
        this.error.set(e.message || this.i18n.t('error'));
      },
    });
  }
}
