import { Component, computed, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DecimalPipe } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { PlatformApi } from '../../core/api/platform.api';
import { TenantRow } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { HdState } from '../../shared/state';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatIconModule } from '@angular/material/icon';
import { MAISON, onColor } from '../../shared/maison';

@Component({
  selector: 'app-tenants-page',
  imports: [
    RouterLink,
    MatButtonModule,
    MatIconModule,
    TranslatePipe,
    DecimalPipe,
    HdState,
    MatPaginatorModule,
    MAISON,
  ],
  template: `
    <div class="hd-page">
      <header class="hd-head">
        <div [mReveal]="0">
          <p class="hd-kicker">{{ 'nav.control' | t }}</p>
          <h1 class="hd-h">{{ 'tenants.title' | t }}</h1>
          <p class="hd-lead">{{ 'tenants.lead' | t }}</p>
          <span class="m-rule" [mReveal]="1"></span>
        </div>
        <a mat-flat-button routerLink="/tenants/new" [mReveal]="1">
          <mat-icon>add</mat-icon>{{ 'tenants.new' | t }}
        </a>
      </header>
      <label class="hd-search" [mReveal]="2">
        <mat-icon aria-hidden="true">search</mat-icon>
        <input
          type="search"
          [attr.aria-label]="'tenants.search' | t"
          [placeholder]="'tenants.search' | t"
          (input)="q.set($any($event.target).value); pageIndex.set(0)"
        />
      </label>
      @if (!loading() && !error()) {
        <div class="grid">
          @for (row of paged(); track row.id; let i = $index) {
            <a class="store m-lift m-press" [routerLink]="['/tenants', row.id]" [mReveal]="i">
              <span
                class="band"
                [style.background]="row.branding?.primary || '#071345'"
                [style.color]="on(row.branding?.primary || '#071345')"
              >
                <span class="logo">
                  @if (row.branding?.logo) {
                    <img [src]="row.branding.logo" [alt]="row.name" loading="lazy" />
                  } @else {
                    <span class="mono" [style.color]="row.branding?.accent || '#c9a45c'">{{
                      initial(row.name)
                    }}</span>
                  }
                </span>
                <span class="swatches" aria-hidden="true">
                  <i [style.background]="row.branding?.primary || '#071345'"></i>
                  <i [style.background]="row.branding?.accent || '#c9a45c'"></i>
                </span>
                <span class="accent-rule" [style.background]="row.branding?.accent || '#c9a45c'"></span>
              </span>
              <span class="body">
                <span class="top">
                  <span class="id">
                    <strong>{{ row.name }}</strong>
                    <small>{{ row.slug }} · {{ row.currency }}</small>
                  </span>
                  <span
                    class="hd-pill"
                    [class.on]="row.status === 'active'"
                    [class.off]="row.status !== 'active'"
                  >
                    {{ row.status === 'active' ? ('common.active' | t) : ('common.suspended' | t) }}
                  </span>
                </span>
                <span class="channels">
                  <span class="ch" [class.on]="row.channels.website">
                    <mat-icon aria-hidden="true">language</mat-icon>{{ 'tenants.website' | t }}
                  </span>
                  <span class="ch" [class.on]="row.channels.admin">
                    <mat-icon aria-hidden="true">dashboard</mat-icon>{{ 'tenants.admin' | t }}
                  </span>
                  <span class="ch" [class.on]="row.channels.mobile">
                    <mat-icon aria-hidden="true">smartphone</mat-icon>{{ 'tenants.mobile' | t }}
                  </span>
                </span>
                <span class="meta">
                  <span><b class="m-num">{{ row.customers || 0 | number }}</b>{{ 'tenants.customers' | t }}</span>
                  <span><b class="m-num">{{ row.products || 0 | number }}</b>{{ 'tenants.products' | t }}</span>
                  <span><b class="m-num">{{ row.orders || 0 | number }}</b>{{ 'tenants.orders' | t }}</span>
                </span>
              </span>
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
      @if (loading()) {
        <div class="grid" aria-busy="true">
          @for (i of skeleton; track i) {
            <div class="store sk">
              <span class="hd-sk" style="height: 112px; border-radius: 0"></span>
              <span class="body">
                <span class="hd-sk" style="height: 16px; width: 55%"></span>
                <span class="hd-sk" style="height: 12px; width: 35%"></span>
                <span class="hd-sk" style="height: 28px; width: 80%; margin-top: 8px"></span>
              </span>
            </div>
          }
        </div>
      }
      <hd-state
        [loading]="false"
        [error]="error()"
        [empty]="!loading() && !filtered().length"
        icon="storefront"
        (retry)="load()"
      />
    </div>
  `,
  styles: `
    .hd-search {
      margin-bottom: 24px;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(min(300px, 100%), 1fr));
      gap: 20px;
    }
    .store {
      display: flex;
      flex-direction: column;
      overflow: hidden;
      text-decoration: none;
      color: inherit;
      background: var(--m-surface);
      border: 1px solid var(--m-line);
      border-radius: var(--m-r-lg);
      box-shadow: var(--m-shadow-1), var(--m-highlight);
    }
    .band {
      position: relative;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      height: 112px;
      padding: 0 22px;
      box-sizing: border-box;
    }
    .band::after {
      content: '';
      position: absolute;
      inset: 0;
      background: radial-gradient(120% 120% at 100% 0%, rgb(255 255 255 / 0.12), transparent 55%);
      pointer-events: none;
    }
    .logo {
      display: grid;
      place-items: center;
      height: 56px;
      max-width: 60%;
    }
    .logo img {
      max-height: 56px;
      max-width: 100%;
      object-fit: contain;
    }
    .mono {
      display: grid;
      place-items: center;
      width: 56px;
      height: 56px;
      border-radius: 50%;
      border: 1px solid currentColor;
      font-family: var(--m-font-display);
      font-size: 26px;
      font-weight: 600;
    }
    .swatches {
      display: flex;
      align-self: flex-end;
      margin-bottom: 16px;
    }
    .swatches i {
      width: 22px;
      height: 22px;
      border-radius: 50%;
      border: 2px solid rgb(255 255 255 / 0.85);
      box-shadow: 0 1px 4px rgb(0 0 0 / 0.25);
    }
    .swatches i + i {
      margin-inline-start: -8px;
    }
    .accent-rule {
      position: absolute;
      inset-inline: 0;
      bottom: 0;
      height: 3px;
    }
    .body {
      display: grid;
      gap: 14px;
      padding: 18px 22px 20px;
    }
    .top {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 10px;
    }
    .id {
      display: grid;
      min-width: 0;
    }
    .id strong {
      font-family: var(--m-font-display);
      font-size: 20px;
      font-weight: 600;
      line-height: 1.25;
    }
    .id small {
      color: var(--m-ink-muted);
      font-size: 12px;
    }
    .channels {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }
    .ch {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      height: 28px;
      padding: 0 10px;
      border-radius: var(--m-r-pill);
      border: 1px solid var(--m-line);
      color: var(--m-ink-muted);
      font-size: 12px;
      font-weight: 500;
      text-decoration: line-through;
      text-decoration-color: color-mix(in srgb, var(--m-ink-muted) 50%, transparent);
    }
    .ch.on {
      color: var(--m-ink);
      text-decoration: none;
      background: var(--m-surface-2);
      border-color: transparent;
    }
    .ch mat-icon {
      font-size: 15px;
      width: 15px;
      height: 15px;
    }
    .ch.on mat-icon {
      color: var(--m-accent-ink);
    }
    .meta {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 8px;
      padding-top: 14px;
      border-top: 1px solid var(--m-line);
      color: var(--m-ink-muted);
      font-size: 12px;
    }
    .meta span {
      display: grid;
    }
    .meta b {
      color: var(--m-ink);
      font-family: var(--m-font-display);
      font-size: 18px;
      font-weight: 600;
    }
    .sk {
      pointer-events: none;
    }
    mat-paginator {
      margin-top: 16px;
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
  readonly skeleton = [0, 1, 2];
  readonly on = onColor;
  initial(name: string): string {
    return (name || '?').trim().charAt(0).toUpperCase();
  }
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
