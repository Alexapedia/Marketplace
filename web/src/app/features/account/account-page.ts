import { Component, inject, OnInit, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { AuthService } from '../../core/auth/auth.service';
import { AppPublicConfig, media } from '../../core/models/models';
import { I18nService } from '../../core/i18n/i18n.service';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-account-page',
  imports: [RouterLink, PageBar, TranslatePipe],
  templateUrl: './account-page.html',
})
export class AccountPage implements OnInit {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiClient);
  private readonly router = inject(Router);
  private readonly toast = inject(ToastService);
  private readonly i18n = inject(I18nService);

  supportEmail = signal('');
  supportPhone = signal('');
  readonly media = media;

  ngOnInit(): void {
    this.api.get<AppPublicConfig>('/app/config').subscribe({
      next: (res) => {
        this.supportEmail.set(res.data?.settings?.supportEmail || '');
        this.supportPhone.set(res.data?.settings?.supportPhone || '');
      },
    });
  }

  callSupport(): void {
    const phone = this.supportPhone();
    if (phone) window.location.href = `tel:${phone.replace(/[^\d+]/g, '')}`;
  }

  emailSupport(): void {
    const email = this.supportEmail();
    if (email) {
      window.open(
        `https://mail.google.com/mail/?view=cm&fs=1&to=${encodeURIComponent(email)}`,
        '_blank',
      );
    }
  }

  deleteAccount(): void {
    if (!confirm(this.i18n.t('deleteAccountConfirm'))) return;
    this.auth.deleteAccount().subscribe({
      next: () => {
        this.toast.show(this.i18n.t('accountDeleted'));
        void this.router.navigate(['/']);
      },
      error: (e) => this.toast.show(e.message),
    });
  }
}
