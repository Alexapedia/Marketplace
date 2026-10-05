import { Component, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { DecimalPipe } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { PlatformApi } from '../../core/api/platform.api';
import { TenantRow } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-tenant-detail-page',
  imports: [
    RouterLink,
    ReactiveFormsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatSlideToggleModule,
    TranslatePipe,
    DecimalPipe,
  ],
  template: `
    <div class="hd-page">
      <a class="back" routerLink="/tenants">{{ 'common.back' | t }}</a>
      @if (row(); as t) {
        <header class="intro">
          <div>
            <p class="hd-kicker">{{ t.slug }}</p>
            <h2 class="hd-h">{{ t.name }}</h2>
          </div>
          <span class="hd-pill" [class.on]="t.status === 'active'" [class.off]="t.status !== 'active'">
            {{ t.status === 'active' ? ('common.active' | t) : ('common.suspended' | t) }}
          </span>
        </header>
        <div class="kpis">
          <article class="hd-card hd-kpi"><span>{{ 'tenants.customers' | t }}</span><strong>{{ t.customers || 0 | number }}</strong></article>
          <article class="hd-card hd-kpi"><span>{{ 'tenants.products' | t }}</span><strong>{{ t.products || 0 | number }}</strong></article>
          <article class="hd-card hd-kpi"><span>{{ 'tenants.orders' | t }}</span><strong>{{ t.orders || 0 | number }}</strong></article>
          <article class="hd-card hd-kpi"><span>{{ 'tenants.staff' | t }}</span><strong>{{ (t.staff || []).length | number }}</strong></article>
        </div>
        <div class="grid">
          <section class="hd-card">
            <h3>{{ 'reports.matrix' | t }}</h3>
            <div class="toggles">
              <mat-slide-toggle [checked]="t.channels.website" (change)="setChannel('website', $event.checked)">{{ 'tenants.website' | t }}</mat-slide-toggle>
              <mat-slide-toggle [checked]="t.channels.admin" (change)="setChannel('admin', $event.checked)">{{ 'tenants.admin' | t }}</mat-slide-toggle>
              <mat-slide-toggle [checked]="t.channels.mobile" (change)="setChannel('mobile', $event.checked)">{{ 'tenants.mobile' | t }}</mat-slide-toggle>
            </div>
            <button mat-stroked-button (click)="toggleStatus()">
              {{ t.status === 'active' ? ('tenants.suspend' | t) : ('tenants.activate' | t) }}
            </button>
          </section>
          <section class="hd-card">
            <h3>{{ 'tenants.branding' | t }}</h3>
            <form [formGroup]="brand" (ngSubmit)="saveBrand()" class="form">
              <mat-form-field><mat-label>{{ 'tenants.name' | t }}</mat-label><input matInput formControlName="name" /></mat-form-field>
              <mat-form-field><mat-label>{{ 'tenants.currency' | t }}</mat-label><input matInput formControlName="currency" /></mat-form-field>
              <mat-form-field><mat-label>{{ 'tenants.primary' | t }}</mat-label><input matInput formControlName="primary" /></mat-form-field>
              <mat-form-field><mat-label>{{ 'tenants.accent' | t }}</mat-label><input matInput formControlName="accent" /></mat-form-field>
              <button mat-flat-button type="submit">{{ 'common.save' | t }}</button>
            </form>
          </section>
        </div>
        <section class="hd-card">
          <h3>{{ 'tenants.domains' | t }}</h3>
          @for (d of t.domains || []; track d.host) {
            <p class="domain"><strong>{{ d.host }}</strong> · {{ d.channel }}</p>
          } @empty {
            <p class="muted">{{ 'common.empty' | t }}</p>
          }
        </section>
        <section class="hd-card">
          <h3>{{ 'tenants.staff' | t }}</h3>
          @for (s of t.staff || []; track s._id) {
            <div class="staff">
              <div>
                <strong>{{ s.name }}</strong>
                <span>{{ s.email }} · {{ s.role }} · 2FA {{ s.totpEnabled ? ('common.enabled' | t) : ('common.disabled' | t) }}</span>
              </div>
              <button mat-stroked-button (click)="reset2fa(s._id)">{{ 'tenants.reset2fa' | t }}</button>
            </div>
          } @empty {
            <p class="muted">{{ 'common.empty' | t }}</p>
          }
        </section>
      } @else if (error()) {
        <p class="err">{{ error() }}</p>
      } @else {
        <p>{{ 'common.loading' | t }}</p>
      }
    </div>
  `,
  styles: `
    .back { color: var(--zz-muted); text-decoration: none; font-size: 13px; font-weight: 700; }
    .intro { display: flex; justify-content: space-between; align-items: end; gap: 12px; margin: 8px 0 16px; }
    .kpis { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-bottom: 14px; }
    .grid { display: grid; grid-template-columns: 1fr 1.2fr; gap: 12px; margin-bottom: 14px; }
    h3 { margin: 0 0 12px; font-size: 15px; }
    .toggles { display: flex; gap: 18px; flex-wrap: wrap; margin-bottom: 14px; }
    .form { display: grid; grid-template-columns: 1fr 1fr; gap: 8px 16px; }
    .staff { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-top: 1px solid var(--zz-line); gap: 12px; }
    .staff span, .muted, .domain { color: var(--zz-muted); font-size: 13px; }
    .staff span { display: block; }
    .err { color: #9f1239; }
    @media (max-width: 900px) {
      .kpis, .grid, .form { grid-template-columns: 1fr; }
    }
  `,
})
export class TenantDetailPage {
  private readonly api = inject(PlatformApi);
  private readonly route = inject(ActivatedRoute);
  private readonly fb = inject(FormBuilder);
  readonly row = signal<TenantRow | null>(null);
  readonly error = signal<string | null>(null);
  readonly brand = this.fb.nonNullable.group({
    name: [''],
    currency: ['SAR'],
    primary: ['#071345'],
    accent: ['#c9a45c'],
  });

  constructor() {
    this.reload();
  }

  private id(): string {
    return this.route.snapshot.paramMap.get('id') || '';
  }

  private reload(): void {
    this.api.tenant(this.id()).subscribe({
      next: (res) => {
        this.row.set(res.data);
        this.brand.patchValue({
          name: res.data.branding?.name || res.data.name,
          currency: res.data.currency || 'SAR',
          primary: res.data.branding?.primary || '#071345',
          accent: res.data.branding?.accent || '#c9a45c',
        });
      },
      error: (err: Error) => this.error.set(err.message),
    });
  }

  setChannel(channel: 'website' | 'admin' | 'mobile', enabled: boolean): void {
    this.api.setChannel(this.id(), channel, enabled).subscribe({
      next: () => this.reload(),
      error: (err: Error) => this.error.set(err.message),
    });
  }

  toggleStatus(): void {
    const next = this.row()?.status === 'active' ? 'suspended' : 'active';
    this.api.setStatus(this.id(), next).subscribe({
      next: () => this.reload(),
      error: (err: Error) => this.error.set(err.message),
    });
  }

  saveBrand(): void {
    const v = this.brand.getRawValue();
    this.api
      .patch(this.id(), {
        currency: v.currency,
        branding: { name: v.name, primary: v.primary, accent: v.accent },
      })
      .subscribe({
        next: () => this.reload(),
        error: (err: Error) => this.error.set(err.message),
      });
  }

  reset2fa(userId: string): void {
    this.api.reset2fa(this.id(), userId).subscribe({
      next: () => this.reload(),
      error: (err: Error) => this.error.set(err.message),
    });
  }
}
