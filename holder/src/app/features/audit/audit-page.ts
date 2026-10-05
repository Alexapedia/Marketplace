import { Component, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { PlatformApi } from '../../core/api/platform.api';
import { PlatformAudit } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-audit-page',
  imports: [TranslatePipe, DatePipe],
  template: `
    <div class="hd-page">
      <p class="hd-kicker">{{ 'nav.insights' | t }}</p>
      <h2 class="hd-h">{{ 'audit.title' | t }}</h2>
      <p class="hd-lead">{{ 'audit.lead' | t }}</p>
      <div class="list">
        @for (item of rows(); track item._id) {
          <article class="hd-card row">
            <div>
              <strong>{{ item.action }}</strong>
              <small>{{ 'audit.tenant' | t }} · {{ item.tenantId || '—' }}</small>
            </div>
            <span>{{ item.createdAt | date: 'medium' }}</span>
          </article>
        } @empty {
          <p>{{ 'common.empty' | t }}</p>
        }
      </div>
    </div>
  `,
  styles: `
    .hd-lead { margin-bottom: 16px; }
    .list { display: grid; gap: 8px; }
    .row {
      display: flex;
      justify-content: space-between;
      gap: 16px;
      align-items: center;
    }
    .row small, .row span { display: block; color: var(--zz-muted); font-size: 13px; }
    .row small { margin-top: 4px; }
  `,
})
export class AuditPage {
  private readonly api = inject(PlatformApi);
  readonly rows = signal<PlatformAudit[]>([]);

  constructor() {
    this.api.audit().subscribe({
      next: (res) => this.rows.set(res.data || []),
    });
  }
}
