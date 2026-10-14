import { Component, computed, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DecimalPipe } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { PlatformApi } from '../../core/api/platform.api';
import { TenantRow } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { HdState } from '../../shared/state';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';

@Component({
  selector: 'app-tenants-page',
  imports: [RouterLink, MatButtonModule, TranslatePipe, DecimalPipe, HdState, MatPaginatorModule],
  template: `
    <div class="hd-page">
      <div class="intro">
        <div>
          <p class="hd-kicker">{{ 'nav.control' | t }}</p>
          <h2 class="hd-h">{{ 'tenants.title' | t }}</h2>
        </div>
        <a mat-flat-button routerLink="/tenants/new">{{ 'tenants.new' | t }}</a>
      </div>
      <input
        class="hd-search"
        type="search"
        [placeholder]="'tenants.search' | t"
        (input)="q.set($any($event.target).value); pageIndex.set(0)"
      />
      @if (!loading() && !error()) {
        <div class="grid">
          @for (row of paged(); track row.id) {
            <a class="hd-card store" [routerLink]="['/tenants', row.id]">
              <div class="top">
                <div>
                  <strong>{{ row.name }}</strong>
                  <small>{{ row.slug }}</small>
                </div>
                <span
                  class="hd-pill"
                  [class.on]="row.status === 'active'"
                  [class.off]="row.status !== 'active'"
                >
                  {{ row.status === 'active' ? ('common.active' | t) : ('common.suspended' | t) }}
                </span>
              </div>
              <div class="channels">
                <span
                  class="hd-pill"
                  [class.on]="row.channels.website"
                  [class.off]="!row.channels.website"
                  >{{ 'tenants.website' | t }}</span
                >
                <span
                  class="hd-pill"
                  [class.on]="row.channels.admin"
                  [class.off]="!row.channels.admin"
                  >{{ 'tenants.admin' | t }}</span
                >
                <span
                  class="hd-pill"
                  [class.on]="row.channels.mobile"
                  [class.off]="!row.channels.mobile"
                  >{{ 'tenants.mobile' | t }}</span
                >
              </div>
              <div class="meta">
                <span>{{ row.customers || 0 | number }} {{ 'tenants.customers' | t }}</span>
                <span>{{ row.products || 0 | number }} {{ 'tenants.products' | t }}</span>
                <span>{{ row.orders || 0 | number }} {{ 'tenants.orders' | t }}</span>
              </div>
            </a>
          }
        </div>
        @if (filtered().length > pageSize) {
          <mat-paginator
            [length]="filtered().length"
            [pageSize]="pageSize"
            [pageIndex]="pageIndex()"
            [hidePageSize]="true"
            (page)="onPage($event)"
          />
        }
      }
      <hd-state
        [loading]="loading()"
        [error]="error()"
        [empty]="!filtered().length"
        (retry)="load()"
      />
    </div>
  `,
  styles: `
    .intro {
      display: flex;
      justify-content: space-between;
      gap: 12px;
      align-items: end;
      margin-bottom: 16px;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 12px;
    }
    .store {
      text-decoration: none;
      color: inherit;
      display: grid;
      gap: 12px;
    }
    .top {
      display: flex;
      justify-content: space-between;
      gap: 10px;
    }
    .top small {
      display: block;
      color: var(--zz-muted);
      font-size: 12px;
      margin-top: 2px;
    }
    .channels {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }
    .meta {
      display: flex;
      gap: 12px;
      color: var(--zz-muted);
      font-size: 12px;
      font-weight: 600;
    }
    .err {
      color: #9f1239;
    }
  `,
})
export class TenantsPage {
  private readonly api = inject(PlatformApi);
  readonly rows = signal<TenantRow[]>([]);
  readonly error = signal<string | null>(null);
  readonly q = signal('');
  readonly loading = signal(true);
  readonly pageIndex = signal(0);
  readonly pageSize = 12;
  readonly paged = computed(() =>
    this.filtered().slice(this.pageIndex() * this.pageSize, (this.pageIndex() + 1) * this.pageSize),
  );
  readonly filtered = computed(() => {
    const needle = this.q().trim().toLowerCase();
    if (!needle) return this.rows();
    return this.rows().filter(
      (row) => row.name.toLowerCase().includes(needle) || row.slug.toLowerCase().includes(needle),
    );
  });

  constructor() {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.tenants().subscribe({
      next: (res) => {
        this.rows.set(res.data || []);
        this.loading.set(false);
      },
      error: (err: Error) => {
        this.error.set(err.message);
        this.loading.set(false);
      },
    });
  }

  onPage(ev: PageEvent): void {
    this.pageIndex.set(ev.pageIndex);
  }
}
