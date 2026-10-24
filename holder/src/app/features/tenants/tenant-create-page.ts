import { Component, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { map, startWith } from 'rxjs';
import { MatIconModule } from '@angular/material/icon';
import { MAISON } from '../../shared/maison';
import { HdBrandPreview } from '../../shared/brand-preview';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { PlatformApi } from '../../core/api/platform.api';
import { CURRENCY_CODES } from '../../core/config/currency';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-tenant-create-page',
  imports: [
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    TranslatePipe,
    RouterLink,
    MAISON,
    HdBrandPreview,
  ],
  template: `
    <div class="hd-page">
      <a class="back m-press" routerLink="/tenants">
        <mat-icon aria-hidden="true" class="flip">arrow_back</mat-icon>{{ 'common.back' | t }}
      </a>
      <header class="hd-head">
        <div [mReveal]="0">
          <p class="hd-kicker">{{ 'nav.control' | t }}</p>
          <h1 class="hd-h">{{ 'tenants.new' | t }}</h1>
          <p class="hd-lead">{{ 'tenants.createLead' | t }}</p>
          <span class="m-rule" [mReveal]="1"></span>
        </div>
      </header>
      <form [formGroup]="form" (ngSubmit)="submit()" class="layout">
        <div class="col">
          <section class="hd-card" [mReveal]="1">
            <h2 class="hd-card-title">{{ 'tenants.identity' | t }}</h2>
            <div class="two">
              <mat-form-field><mat-label>{{ 'tenants.slug' | t }}</mat-label><input matInput formControlName="slug" /></mat-form-field>
              <mat-form-field><mat-label>{{ 'tenants.name' | t }}</mat-label><input matInput formControlName="name" /></mat-form-field>
              <mat-form-field>
                <mat-label>{{ 'tenants.currency' | t }}</mat-label>
                <mat-select formControlName="currency">
                  @for (code of currencies; track code) {
                    <mat-option [value]="code">{{ code }}</mat-option>
                  }
                </mat-select>
              </mat-form-field>
            </div>
          </section>
          <section class="hd-card" [mReveal]="2">
            <h2 class="hd-card-title">{{ 'tenants.firstAdmin' | t }}</h2>
            <div class="two">
              <mat-form-field><mat-label>{{ 'tenants.adminEmail' | t }}</mat-label><input matInput type="email" formControlName="adminEmail" /></mat-form-field>
              <mat-form-field><mat-label>{{ 'tenants.adminPassword' | t }}</mat-label><input matInput type="password" formControlName="adminPassword" /></mat-form-field>
            </div>
          </section>
          <section class="hd-card" [mReveal]="3">
            <h2 class="hd-card-title">{{ 'tenants.hosts' | t }}</h2>
            <div class="two">
              <mat-form-field><mat-label>{{ 'tenants.websiteHost' | t }}</mat-label><input matInput formControlName="websiteHost" /></mat-form-field>
              <mat-form-field><mat-label>{{ 'tenants.adminHost' | t }}</mat-label><input matInput formControlName="adminHost" /></mat-form-field>
            </div>
          </section>
        </div>
        <aside class="col">
          <section class="hd-card" [mReveal]="4">
            <h2 class="hd-card-title">{{ 'tenants.colors' | t }}</h2>
            <div class="colors">
              <mat-form-field>
                <mat-label>{{ 'tenants.primary' | t }}</mat-label>
                <span matTextPrefix class="sw" [style.background]="v().primary"></span>
                <input matInput formControlName="primary" dir="ltr" />
              </mat-form-field>
              <mat-form-field>
                <mat-label>{{ 'tenants.accent' | t }}</mat-label>
                <span matTextPrefix class="sw" [style.background]="v().accent"></span>
                <input matInput formControlName="accent" dir="ltr" />
              </mat-form-field>
            </div>
            <p class="m-eyebrow pv">{{ 'tenants.preview' | t }}</p>
            <hd-brand-preview [name]="v().name" [primary]="v().primary" [accent]="v().accent" />
          </section>
          @if (error()) { <p class="err" role="alert">{{ error() }}</p> }
          <button mat-flat-button type="submit" class="go" [disabled]="loading()">
            <mat-icon>add_business</mat-icon>{{ 'common.create' | t }}
          </button>
        </aside>
      </form>
    </div>
  `,
  styles: `
    .back {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      min-height: 44px;
      color: var(--m-ink-muted);
      text-decoration: none;
      font-size: 13px;
      font-weight: 600;
    }
    .back:hover { color: var(--m-ink); }
    .back mat-icon { font-size: 18px; width: 18px; height: 18px; }
    :host-context([dir='rtl']) .flip { transform: scaleX(-1); }
    .layout {
      display: grid;
      grid-template-columns: minmax(0, 1.4fr) minmax(0, 1fr);
      gap: 20px;
      align-items: start;
    }
    .col { display: grid; gap: 20px; }
    .two {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px 16px;
    }
    .colors { display: grid; gap: 12px; margin-bottom: 20px; }
    .sw {
      display: inline-block;
      width: 18px;
      height: 18px;
      border-radius: 50%;
      margin-inline-end: 10px;
      vertical-align: -3px;
      box-shadow: 0 0 0 1px var(--m-line);
    }
    .pv { margin: 0 0 12px; }
    .go { justify-self: stretch; }
    .err {
      margin: 0;
      padding: 12px 14px;
      border-radius: var(--m-r-sm);
      background: color-mix(in srgb, var(--m-danger) 12%, var(--m-surface));
      color: var(--m-danger);
      font-size: 13px;
    }
    @media (max-width: 1023.98px) {
      .layout { grid-template-columns: 1fr; }
    }
    @media (max-width: 599.98px) {
      .two { grid-template-columns: 1fr; }
    }
  `,
})
export class TenantCreatePage {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(PlatformApi);
  private readonly router = inject(Router);
  readonly currencies = CURRENCY_CODES;
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);

  readonly form = this.fb.nonNullable.group({
    slug: ['', Validators.required],
    name: ['', Validators.required],
    adminEmail: ['', [Validators.required, Validators.email]],
    adminPassword: ['', [Validators.required, Validators.minLength(8)]],
    websiteHost: [''],
    adminHost: [''],
    currency: ['SAR'],
    primary: ['#071345'],
    accent: ['#c9a45c'],
  });
  /** Live values for the brand preview (visual only). */
  readonly v = toSignal(
    this.form.valueChanges.pipe(
      startWith(null),
      map(() => this.form.getRawValue()),
    ),
    { initialValue: this.form.getRawValue() },
  );

  submit(): void {
    if (this.form.invalid || this.loading()) {
      this.form.markAllAsTouched();
      return;
    }
    this.loading.set(true);
    this.error.set(null);
    const v = this.form.getRawValue();
    const domains = [
      v.websiteHost ? { host: v.websiteHost, channel: 'website' as const } : null,
      v.adminHost ? { host: v.adminHost, channel: 'admin' as const } : null,
    ].filter((d): d is { host: string; channel: 'website' | 'admin' } => !!d);
    this.api
      .create({
        slug: v.slug,
        name: v.name,
        adminEmail: v.adminEmail,
        adminPassword: v.adminPassword,
        currency: v.currency,
        domains,
        branding: { name: v.name, primary: v.primary, accent: v.accent },
      })
      .subscribe({
        next: (res) => void this.router.navigate(['/tenants', res.data.id]),
        error: (err: Error) => {
          this.loading.set(false);
          this.error.set(err.message);
        },
      });
  }
}
