import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/auth/auth.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { AuthEye } from '../../shared/auth-eye';
import { AuthLayout } from '../../shared/auth-layout';

@Component({
  selector: 'app-login-page',
  imports: [FormsModule, RouterLink, TranslatePipe, AuthLayout, AuthEye],
  templateUrl: './login-page.html',
})
export class LoginPage {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  readonly i18n = inject(I18nService);

  email = '';
  password = '';
  error = signal('');
  loading = signal(false);
  hide = signal(true);

  submit(ev: Event): void {
    ev.preventDefault();
    if (this.loading()) return;
    this.error.set('');
    this.loading.set(true);
    this.auth.login(this.email, this.password).subscribe({
      next: () => void this.router.navigate(['/']),
      error: (e) => {
        this.loading.set(false);
        this.error.set(e.message || this.i18n.t('error'));
      },
    });
  }
}
