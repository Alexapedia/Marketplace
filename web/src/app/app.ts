import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ApiClient } from './core/api/api-client';
import { I18nService } from './core/i18n/i18n.service';
import { ThemeService } from './core/theme/theme.service';
import { ToastService } from './core/toast/toast.service';
import { StoreConfigService } from './core/config/store-config.service';
import { TranslatePipe } from './core/i18n/translate.pipe';
import { TelemetryService } from './core/telemetry/telemetry.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, TranslatePipe],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  readonly toast = inject(ToastService);
  readonly store = inject(StoreConfigService);

  constructor() {
    inject(ThemeService);
    inject(I18nService);
    inject(TelemetryService).boot('website');
    const api = inject(ApiClient);
    let session = localStorage.getItem('zz_visit_session');
    if (!session) {
      session = String(Date.now());
      localStorage.setItem('zz_visit_session', session);
    }
    api.post('/analytics/visit', { platform: 'website', path: '/', sessionId: session }).subscribe({
      error: () => undefined,
    });
  }
}
