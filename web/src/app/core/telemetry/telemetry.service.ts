import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class TelemetryService {
  private readonly http = inject(HttpClient);
  private lastKey = '';
  private lastAt = 0;
  private channel: 'holder' | 'website' | 'admin' = 'website';

  boot(channel: 'holder' | 'website' | 'admin'): void {
    this.channel = channel;
    window.addEventListener('error', (ev) => {
      this.report(
        'crash',
        ev.message || 'Window error',
        ev.error instanceof Error ? ev.error.stack : undefined,
      );
    });
    window.addEventListener('unhandledrejection', (ev) => {
      const reason = ev.reason;
      const message = reason instanceof Error ? reason.message : String(reason || 'Unhandled rejection');
      const stack = reason instanceof Error ? reason.stack : undefined;
      this.report('error', message, stack);
    });
  }

  report(kind: 'crash' | 'error' | 'issue', message: string, stack?: string): void {
    const key = `${kind}:${message}`;
    const now = Date.now();
    if (this.lastKey === key && now - this.lastAt < 15000) {
      return;
    }
    this.lastKey = key;
    this.lastAt = now;
    this.http
      .post(`${environment.apiUrl}/telemetry/events`, {
        kind,
        channel: this.channel,
        message: String(message).slice(0, 500),
        stack: stack ? String(stack).slice(0, 4000) : undefined,
        url: window.location.href,
      })
      .subscribe({ error: () => undefined });
  }
}
