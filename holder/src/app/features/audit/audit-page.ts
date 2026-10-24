import { Component, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { PlatformApi } from '../../core/api/platform.api';
import { PageMeta, PlatformAudit, TenantRow } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { HdState } from '../../shared/state';
import { MatIconModule } from '@angular/material/icon';
import { MAISON } from '../../shared/maison';

const PAGE = 25;

@Component({
  selector: 'app-audit-page',
  imports: [
    TranslatePipe,
    DatePipe,
    MatFormFieldModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    HdState,
    MAISON,
  ],
  template: `
    <div class="hd-page">
      <header class="hd-head">
        <div [mReveal]="0">
          <p class="hd-kicker">{{ 'nav.insights' | t }}</p>
          <h1 class="hd-h">{{ 'audit.title' | t }}</h1>
          <p class="hd-lead">{{ 'audit.lead' | t }}</p>
          <span class="m-rule" [mReveal]="1"></span>
        </div>
        <mat-form-field class="filter" subscriptSizing="dynamic" [mReveal]="1">
          <mat-label>{{ 'audit.tenant' | t }}</mat-label>
          <mat-icon matPrefix aria-hidden="true">storefront</mat-icon>
          <mat-select [value]="tenantId()" (selectionChange)="filter($event.value)">
            <mat-option value="">{{ 'common.all' | t }}</mat-option>
            @for (t of tenants(); track t.id) {
              <mat-option [value]="t.id">{{ t.name }}</mat-option>
            }
          </mat-select>
        </mat-form-field>
      </header>
      @if (!loading()) {
        @if (rows().length) {
          <ol class="timeline hd-card">
            @for (item of rows(); track item._id; let i = $index) {
              <li class="row m-enter" [style.animation-delay.ms]="i < 12 ? i * 30 : 360">
                <span class="dot" aria-hidden="true"><mat-icon>{{ iconFor(item.action) }}</mat-icon></span>
                <div class="what">
                  <strong>{{ item.action }}</strong>
                  <small
                    >{{ 'audit.tenant' | t }} · {{ item.tenantName || item.tenantId || '—' }}
                    @if (item.ip) {
                      · <span dir="ltr">{{ item.ip }}</span>
                    }
                  </small>
                </div>
                <time class="when m-num">{{ item.createdAt | date: 'medium' }}</time>
              </li>
            }
          </ol>
        }
        @if (hasMore()) {
          <button
            mat-stroked-button
            class="more"
            [disabled]="loadingMore()"
            (click)="load(meta()!.page + 1)"
          >
            {{ 'common.loadMore' | t }}
          </button>
        }
      }
      <hd-state [loading]="loading()" [error]="error()" [empty]="!rows().length" icon="policy" (retry)="load()" />
    </div>
  `,
  styles: `
    .filter {
      width: min(300px, 100%);
    }
    .filter mat-icon {
      margin-inline: 12px 4px;
      color: var(--m-accent-ink);
    }
    .timeline {
      list-style: none;
      margin: 0;
      padding: 8px 24px;
    }
    .row {
      position: relative;
      display: flex;
      align-items: center;
      gap: 16px;
      min-height: 64px;
      padding: 12px 0;
      border-top: 1px solid var(--m-line);
    }
    .row:first-child {
      border-top: 0;
    }
    .dot {
      display: grid;
      place-items: center;
      width: 36px;
      height: 36px;
      flex: none;
      border-radius: 50%;
      background: var(--m-accent-soft);
      color: var(--m-accent-ink);
    }
    .dot mat-icon {
      font-size: 18px;
      width: 18px;
      height: 18px;
    }
    .what {
      flex: 1;
      min-width: 0;
      display: grid;
      gap: 2px;
    }
    .what strong {
      font-weight: 600;
      overflow-wrap: anywhere;
    }
    small,
    .when {
      color: var(--m-ink-muted);
      font-size: 12px;
    }
    .when {
      flex: none;
      font-size: 13px;
    }
    .more {
      display: block;
      margin: 24px auto 0;
    }
    @media (max-width: 599.98px) {
      .timeline {
        padding: 4px 16px;
      }
      .row {
        flex-wrap: wrap;
        align-items: flex-start;
      }
      .when {
        width: 100%;
        box-sizing: border-box;
        padding-inline-start: 52px;
        font-size: 12px;
      }
    }
  `,
})
export class AuditPage {
  private readonly api = inject(PlatformApi);
  readonly rows = signal<PlatformAudit[]>([]);
  readonly tenants = signal<TenantRow[]>([]);
  readonly tenantId = signal('');
  readonly meta = signal<PageMeta | null>(null);
  readonly loading = signal(true);
  readonly loadingMore = signal(false);
  readonly error = signal<string | null>(null);

  constructor() {
    this.api.tenants().subscribe({
      next: (res) => this.tenants.set(res.data || []),
      error: () => undefined,
    });
    this.load();
  }

  /** Icon for an audit action (visual only). */
  iconFor(action: string): string {
    const a = (action || '').toLowerCase();
    if (a.includes('2fa')) return 'key';
    if (a.includes('channel')) return 'toggle_on';
    if (a.includes('status') || a.includes('suspend')) return 'pause_circle';
    if (a.includes('create')) return 'add_business';
    if (a.includes('domain')) return 'language';
    return 'edit_note';
  }

  hasMore(): boolean {
    const m = this.meta();
    return !!m && m.page < m.totalPages;
  }

  filter(tenantId: string): void {
    this.tenantId.set(tenantId);
    this.load();
  }

  load(page = 1): void {
    if (page === 1) {
      this.loading.set(true);
      this.error.set(null);
    } else {
      this.loadingMore.set(true);
    }
    this.api.audit({ tenantId: this.tenantId() || undefined, page, limit: PAGE }).subscribe({
      next: (res) => {
        const rows = res.data || [];
        this.rows.set(page === 1 ? rows : [...this.rows(), ...rows]);
        this.meta.set(res.meta ?? null);
        this.loading.set(false);
        this.loadingMore.set(false);
      },
      error: (err: Error) => {
        this.error.set(err.message);
        this.loading.set(false);
        this.loadingMore.set(false);
      },
    });
  }
}
