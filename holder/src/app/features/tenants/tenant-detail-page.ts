import { Component, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { DecimalPipe } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatIconModule } from '@angular/material/icon';
import { MatSnackBar } from '@angular/material/snack-bar';
import { filter } from 'rxjs';
import { ConfirmService } from '../../shared/confirm';
import { I18nService } from '../../core/i18n/i18n.service';
import { PlatformApi } from '../../core/api/platform.api';
import { CURRENCY_CODES } from '../../core/config/currency';
import { TenantDomain, TenantRow } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-tenant-detail-page',
  imports: [
    RouterLink,
    ReactiveFormsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatSlideToggleModule,
    MatIconModule,
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
          <span
            class="hd-pill"
            [class.on]="t.status === 'active'"
            [class.off]="t.status !== 'active'"
          >
            {{ t.status === 'active' ? ('common.active' | t) : ('common.suspended' | t) }}
          </span>
        </header>
        <div class="kpis">
          <article class="hd-card hd-kpi">
            <span>{{ 'tenants.customers' | t }}</span
            ><strong>{{ t.customers || 0 | number }}</strong>
          </article>
          <article class="hd-card hd-kpi">
            <span>{{ 'tenants.products' | t }}</span
            ><strong>{{ t.products || 0 | number }}</strong>
          </article>
          <article class="hd-card hd-kpi">
            <span>{{ 'tenants.orders' | t }}</span
            ><strong>{{ t.orders || 0 | number }}</strong>
          </article>
          <article class="hd-card hd-kpi">
            <span>{{ 'tenants.staff' | t }}</span
            ><strong>{{ (t.staff || []).length | number }}</strong>
          </article>
        </div>
        <div class="grid">
          <section class="hd-card">
            <h3>{{ 'reports.matrix' | t }}</h3>
            <div class="toggles">
              <mat-slide-toggle
                [checked]="t.channels.website"
                (change)="setChannel('website', $event.checked)"
                >{{ 'tenants.website' | t }}</mat-slide-toggle
              >
              <mat-slide-toggle
                [checked]="t.channels.admin"
                (change)="setChannel('admin', $event.checked)"
                >{{ 'tenants.admin' | t }}</mat-slide-toggle
              >
              <mat-slide-toggle
                [checked]="t.channels.mobile"
                (change)="setChannel('mobile', $event.checked)"
                >{{ 'tenants.mobile' | t }}</mat-slide-toggle
              >
            </div>
            <button
              mat-stroked-button
              [class.warn-btn]="t.status === 'active'"
              [disabled]="busy()"
              (click)="toggleStatus()"
            >
              {{ t.status === 'active' ? ('tenants.suspend' | t) : ('tenants.activate' | t) }}
            </button>
          </section>
          <section class="hd-card">
            <h3>{{ 'tenants.branding' | t }}</h3>
            <form [formGroup]="brand" (ngSubmit)="saveBrand()" class="form">
              <mat-form-field
                ><mat-label>{{ 'tenants.name' | t }}</mat-label
                ><input matInput formControlName="name"
              /></mat-form-field>
              <mat-form-field>
                <mat-label>{{ 'tenants.currency' | t }}</mat-label>
                <mat-select formControlName="currency">
                  @for (code of currencies; track code) {
                    <mat-option [value]="code">{{ code }}</mat-option>
                  }
                </mat-select>
              </mat-form-field>
              <label class="color">
                <span>{{ 'tenants.primary' | t }}</span>
                <input type="color" formControlName="primary" />
                <code>{{ brand.controls.primary.value }}</code>
              </label>
              <label class="color">
                <span>{{ 'tenants.accent' | t }}</span>
                <input type="color" formControlName="accent" />
                <code>{{ brand.controls.accent.value }}</code>
              </label>
              <div class="preview" [style.background]="brand.controls.primary.value">
                <span [style.color]="brand.controls.accent.value">{{
                  brand.controls.name.value || t.name
                }}</span>
              </div>
              <button mat-flat-button type="submit" [disabled]="busy()">
                {{ 'common.save' | t }}
              </button>
            </form>
          </section>
        </div>
        <section class="hd-card">
          <h3>{{ 'tenants.domains' | t }}</h3>
          <p class="muted">{{ 'tenants.domainsHint' | t }}</p>
          @for (d of domains(); track $index; let i = $index) {
            <div class="domain-row">
              <mat-form-field appearance="outline">
                <mat-label>{{ 'tenants.host' | t }}</mat-label>
                <input
                  matInput
                  [value]="d.host"
                  (input)="patchDomain(i, 'host', $any($event.target).value)"
                  placeholder="shop.example.com"
                />
              </mat-form-field>
              <mat-form-field appearance="outline">
                <mat-label>{{ 'tenants.channel' | t }}</mat-label>
                <mat-select
                  [value]="d.channel"
                  (selectionChange)="patchDomain(i, 'channel', $event.value)"
                >
                  <mat-option value="website">{{ 'tenants.website' | t }}</mat-option>
                  <mat-option value="admin">{{ 'tenants.admin' | t }}</mat-option>
                </mat-select>
              </mat-form-field>
              <button
                mat-icon-button
                type="button"
                (click)="removeDomain(i)"
                [attr.aria-label]="'common.delete' | t"
              >
                <mat-icon>delete</mat-icon>
              </button>
            </div>
          }
          <div class="row-actions">
            <button mat-stroked-button type="button" (click)="addDomain()">
              <mat-icon>add</mat-icon>{{ 'tenants.addDomain' | t }}
            </button>
            <button mat-flat-button type="button" [disabled]="busy()" (click)="saveDomains()">
              {{ 'common.save' | t }}
            </button>
          </div>
        </section>
        <section class="hd-card">
          <h3>{{ 'tenants.staff' | t }}</h3>
          @for (s of t.staff || []; track s._id) {
            <div class="staff">
              <div>
                <strong>{{ s.name }}</strong>
                <span
                  >{{ s.email }} · {{ s.role }} · 2FA
                  {{ s.totpEnabled ? ('common.enabled' | t) : ('common.disabled' | t) }}</span
                >
              </div>
              <button
                mat-stroked-button
                [disabled]="busy() || !s.totpEnabled"
                (click)="reset2fa(s._id)"
              >
                {{ 'tenants.reset2fa' | t }}
              </button>
            </div>
          } @empty {
            <p class="muted">{{ 'common.empty' | t }}</p>
          }
        </section>
      } @else if (error()) {
        <p class="err" role="alert">{{ error() }}</p>
      } @else {
        <p>{{ 'common.loading' | t }}</p>
      }
    </div>
  `,
  styles: `
    .back {
      color: var(--zz-muted);
      text-decoration: none;
      font-size: 13px;
      font-weight: 700;
    }
    .intro {
      display: flex;
      justify-content: space-between;
      align-items: end;
      gap: 12px;
      margin: 8px 0 16px;
    }
    .kpis {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 12px;
      margin-bottom: 14px;
    }
    .grid {
      display: grid;
      grid-template-columns: 1fr 1.2fr;
      gap: 12px;
      margin-bottom: 14px;
    }
    h3 {
      margin: 0 0 12px;
      font-size: 15px;
    }
    .toggles {
      display: flex;
      gap: 18px;
      flex-wrap: wrap;
      margin-bottom: 14px;
    }
    .form {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 8px 16px;
    }
    .staff {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 10px 0;
      border-top: 1px solid var(--zz-line);
      gap: 12px;
    }
    .staff span,
    .muted,
    .domain {
      color: var(--zz-muted);
      font-size: 13px;
    }
    .staff span {
      display: block;
    }
    .err {
      color: #9f1239;
    }
    .color {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 13px;
      color: var(--zz-muted);
    }
    .color input {
      width: 44px;
      height: 36px;
      border: 1px solid var(--zz-line);
      border-radius: 10px;
      padding: 2px;
      background: none;
      cursor: pointer;
    }
    .color code {
      font-size: 12px;
    }
    .preview {
      grid-column: 1 / -1;
      border-radius: 12px;
      padding: 14px 16px;
      font-weight: 800;
    }
    .domain-row {
      display: grid;
      grid-template-columns: 1.6fr 1fr auto;
      gap: 8px;
      align-items: start;
    }
    .row-actions {
      display: flex;
      gap: 8px;
      justify-content: flex-end;
    }
    .warn-btn {
      color: #be123c;
    }
    @media (max-width: 900px) {
      .kpis,
      .grid,
      .form,
      .domain-row {
        grid-template-columns: 1fr;
      }
    }
  `,
})
export class TenantDetailPage {
  private readonly api = inject(PlatformApi);
  private readonly route = inject(ActivatedRoute);
  private readonly fb = inject(FormBuilder);
  private readonly confirm = inject(ConfirmService);
  private readonly snack = inject(MatSnackBar);
  private readonly i18n = inject(I18nService);
  readonly currencies = CURRENCY_CODES;
  readonly busy = signal(false);
  readonly domains = signal<TenantDomain[]>([]);
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
        this.domains.set((res.data.domains || []).map((d) => ({ ...d })));
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

  private done(key: string): void {
    this.busy.set(false);
    this.snack.open(this.i18n.t(key), undefined, { duration: 2600 });
    this.reload();
  }

  private fail(err: Error): void {
    this.busy.set(false);
    this.snack.open(err.message, undefined, { duration: 4200 });
  }

  setChannel(channel: 'website' | 'admin' | 'mobile', enabled: boolean): void {
    this.api.setChannel(this.id(), channel, enabled).subscribe({
      next: () => this.done('common.saved'),
      error: (err: Error) => {
        this.fail(err);
        this.reload();
      },
    });
  }

  toggleStatus(): void {
    const next = this.row()?.status === 'active' ? 'suspended' : 'active';
    const run = () => {
      this.busy.set(true);
      this.api.setStatus(this.id(), next).subscribe({
        next: () => this.done(next === 'suspended' ? 'tenants.suspended' : 'tenants.activated'),
        error: (err: Error) => this.fail(err),
      });
    };
    if (next === 'active') {
      run();
      return;
    }
    this.confirm
      .ask({
        title: 'tenants.suspend',
        message: 'tenants.suspendConfirm',
        confirmKey: 'tenants.suspend',
        danger: true,
      })
      .pipe(filter(Boolean))
      .subscribe(run);
  }

  saveBrand(): void {
    const v = this.brand.getRawValue();
    this.busy.set(true);
    this.api
      .patch(this.id(), {
        currency: v.currency,
        branding: { name: v.name, primary: v.primary, accent: v.accent },
      })
      .subscribe({
        next: () => this.done('common.saved'),
        error: (err: Error) => this.fail(err),
      });
  }

  addDomain(): void {
    this.domains.update((list) => [...list, { host: '', channel: 'website' }]);
  }

  removeDomain(index: number): void {
    this.domains.update((list) => list.filter((_, i) => i !== index));
  }

  patchDomain(index: number, key: 'host' | 'channel', value: string): void {
    this.domains.update((list) =>
      list.map((d, i) => (i === index ? ({ ...d, [key]: value } as TenantDomain) : d)),
    );
  }

  saveDomains(): void {
    const domains = this.domains()
      .map((d) => ({ host: d.host.trim().toLowerCase(), channel: d.channel }))
      .filter((d) => d.host);
    this.busy.set(true);
    this.api.patch(this.id(), { domains }).subscribe({
      next: () => this.done('common.saved'),
      error: (err: Error) => this.fail(err),
    });
  }

  reset2fa(userId: string): void {
    this.confirm
      .ask({
        title: 'tenants.reset2fa',
        message: 'tenants.reset2faConfirm',
        confirmKey: 'tenants.reset2fa',
        danger: true,
      })
      .pipe(filter(Boolean))
      .subscribe(() => {
        this.busy.set(true);
        this.api.reset2fa(this.id(), userId).subscribe({
          next: () => this.done('tenants.reset2faDone'),
          error: (err: Error) => this.fail(err),
        });
      });
  }
}
