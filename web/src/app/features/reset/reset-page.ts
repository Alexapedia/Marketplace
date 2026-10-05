import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/auth/auth.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-reset-page',
  imports: [FormsModule, RouterLink, TranslatePipe],
  templateUrl: './reset-page.html',
})
export class ResetPage {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly toast = inject(ToastService);
  private readonly i18n = inject(I18nService);

  token = this.route.snapshot.queryParamMap.get('token') || '';
  password = '';
  error = signal('');

  submit(ev: Event): void {
    ev.preventDefault();
    this.error.set('');
    this.auth.resetPassword(this.token, this.password).subscribe({
      next: () => {
        this.toast.show(this.i18n.t('resetDone'));
        void this.router.navigate(['/login']);
      },
      error: (e) => this.error.set(e.message),
    });
  }
}
