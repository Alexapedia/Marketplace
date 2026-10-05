import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ApiClient } from './core/api/api-client';
import { I18nService } from './core/i18n/i18n.service';
import { ThemeService } from './core/theme/theme.service';
import { ToastService } from './core/toast/toast.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  readonly toast = inject(ToastService);

  constructor() {
    inject(ThemeService);
    inject(I18nService);
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
