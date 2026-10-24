import { Component, Input, computed, inject } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { I18nService } from '../core/i18n/i18n.service';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { ThemeService } from '../core/theme/theme.service';
import { StoreConfigService } from '../core/config/store-config.service';
import { Icon } from './icon';

export type AuthMode = 'login' | 'register' | 'forgot' | 'reset';

@Component({
  selector: 'app-auth-layout',
  imports: [RouterLink, RouterLinkActive, TranslatePipe, Icon],
  templateUrl: './auth-layout.html',
})
export class AuthLayout {
  @Input({ required: true }) mode!: AuthMode;

  readonly i18n = inject(I18nService);
  readonly theme = inject(ThemeService);
  readonly store = inject(StoreConfigService);
  /** The brand panel is a deep primary band, so prefer the dark-surface logo. */
  readonly logo = computed(() => this.store.logoDark() || this.store.logo());

  get titleKey(): string {
    if (this.mode === 'register') return 'register';
    if (this.mode === 'forgot') return 'forgotPassword';
    if (this.mode === 'reset') return 'resetPassword';
    return 'login';
  }

  get leadKey(): string {
    if (this.mode === 'register') return 'authRegisterLead';
    if (this.mode === 'forgot') return 'forgotHint';
    if (this.mode === 'reset') return 'resetHint';
    return 'authLoginLead';
  }
}
