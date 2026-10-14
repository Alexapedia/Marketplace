import { Component, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { PlatformApi } from '../../core/api/platform.api';
import { PageMeta, PlatformAudit, TenantRow } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { HdState } from '../../shared/state';

const PAGE = 25;

@Component({
  selector: 'app-audit-page',
  imports: [TranslatePipe, DatePipe, MatFormFieldModule, MatSelectModule, MatButtonModule, HdState],
  template: `
    <div class="hd-page">
      <p class="hd-kicker">{{ 'nav.insights' | t }}</p>
      <h2 class="hd-h">{{ 'audit.title' | t }}</h2>
      <p class="hd-lead">{{ 'audit.lead' | t }}</p>
      <mat-form-field appearance="outline" class="filter">
        <mat-label>{{ 'audit.tenant' | t }}</mat-label>
        <mat-select [value]="tenantId()" (selectionChange)="filter($event.value)">
          <mat-option value="">{{ 'common.all' | t }}</mat-option>
          @for (t of tenants(); track t.id) {
            <mat-option [value]="t.id">{{ t.name }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
      @if (!loading()) {
        <div class="list">
          @for (item of rows(); track item._id) {
            <article class="hd-card row">
              <div>
                <strong>{{ item.action }}</strong>
                <small
                  >{{ 'audit.tenant' | t }} · {{ item.tenantName || item.tenantId || '—' }}
                  @if (item.ip) {
                    · {{ item.ip }}
                  }
                </small>
              </div>
              <span>{{ item.createdAt | date: 'medium' }}</span>
            </article>
          }
        </div>
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
      <hd-state [loading]="loading()" [error]="error()" [empty]="!rows().length" (retry)="load()" />
    </div>
  `,
  styles: `
    .hd-lead {
      margin-bottom: 16px;
    }
    .filter {
      min-width: 260px;
    }
    .list {
      display: grid;
      gap: 8px;
    }
    .row {
      display: flex;
      justify-content: space-between;
      gap: 16px;
      align-items: center;
    }
    .row small,
    .row span {
      display: block;
      color: var(--zz-muted);
      font-size: 13px;
    }
    .row small {
      margin-top: 4px;
    }
    .more {
      display: block;
      margin: 16px auto 0;
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
