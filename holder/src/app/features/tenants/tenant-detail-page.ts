import { Component, computed, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatIconModule } from '@angular/material/icon';
import { MatSnackBar } from '@angular/material/snack-bar';
import { filter, map, startWith } from 'rxjs';
import { ConfirmService } from '../../shared/confirm';
import { I18nService } from '../../core/i18n/i18n.service';
import { PlatformApi } from '../../core/api/platform.api';
import { CURRENCY_CODES } from '../../core/config/currency';
import { TenantDomain, TenantRow } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { MAISON, onColor } from '../../shared/maison';
import { HdLogoDrop } from '../../shared/logo-drop';
import { HdBrandPreview } from '../../shared/brand-preview';
import { HdState } from '../../shared/state';

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
    MAISON,
    HdLogoDrop,
    HdBrandPreview,
    HdState,
  ],
  template: `
    <div class="hd-page">
      <a class="back m-press" routerLink="/tenants">
        <mat-icon aria-hidden="true" class="flip">arrow_back</mat-icon>{{ 'common.back' | t }}
      </a>
      @if (row(); as t) {
        <header class="identity" [mReveal]="0">
          <span class="badge" [style.background]="bv().primary" [style.color]="onPrimary()">
            @if (badgeLogo(); as src) {
              <img [src]="src" alt="" />
            } @else {
              <span class="mono" [style.color]="bv().accent">{{ t.name.charAt(0) }}</span>
            }
          </span>
          <div class="id">
            <p class="hd-kicker">{{ t.slug }} · {{ t.currency }}</p>
            <h1 class="hd-h">{{ t.name }}</h1>
            <span class="m-rule" [mReveal]="1"></span>
          </div>
          <span
            class="hd-pill status"
            [class.on]="t.status === 'active'"
            [class.off]="t.status !== 'active'"
          >
            {{ t.status === 'active' ? ('common.active' | t) : ('common.suspended' | t) }}
          </span>
        </header>

        <div class="kpis">
          <article class="hd-card hd-kpi m-lift" [mReveal]="1">
            <span>{{ 'tenants.customers' | t }}</span>
            <strong [mCountUp]="t.customers || 0"></strong>
          </article>
          <article class="hd-card hd-kpi m-lift" [mReveal]="2">
            <span>{{ 'tenants.products' | t }}</span>
            <strong [mCountUp]="t.products || 0"></strong>
          </article>
          <article class="hd-card hd-kpi m-lift" [mReveal]="3">
            <span>{{ 'tenants.orders' | t }}</span>
            <strong [mCountUp]="t.orders || 0"></strong>
          </article>
          <article class="hd-card hd-kpi m-lift" [mReveal]="4">
            <span>{{ 'tenants.staff' | t }}</span>
            <strong [mCountUp]="(t.staff || []).length"></strong>
          </article>
        </div>

        <section class="hd-card brand" [mReveal]="5">
          <h2 class="hd-card-title">{{ 'tenants.branding' | t }}</h2>
          <form [formGroup]="brand" (ngSubmit)="saveBrand()" class="brand-grid">
            <div class="fields">
              <div class="row2">
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
              </div>
              <p class="sub">{{ 'tenants.colors' | t }}</p>
              <div class="row2 colors">
                <label class="color">
                  <span class="swatch" [style.background]="bv().primary">
                    <input type="color" formControlName="primary" />
                  </span>
                  <span class="color-copy">
                    <span>{{ 'tenants.primary' | t }}</span>
                    <code dir="ltr">{{ brand.controls.primary.value }}</code>
                  </span>
                </label>
                <label class="color">
                  <span class="swatch" [style.background]="bv().accent">
                    <input type="color" formControlName="accent" />
                  </span>
                  <span class="color-copy">
                    <span>{{ 'tenants.accent' | t }}</span>
                    <code dir="ltr">{{ brand.controls.accent.value }}</code>
                  </span>
                </label>
              </div>
              <div class="row2 logos">
                <hd-logo-drop
                  label="tenants.logoLight"
                  [value]="bv().logo"
                  (valueChange)="setLogo('logo', $event)"
                />
                <hd-logo-drop
                  label="tenants.logoDark"
                  surface="dark"
                  [value]="bv().logoDark"
                  (valueChange)="setLogo('logoDark', $event)"
                />
              </div>
              <div class="actions">
                @if (brand.dirty) {
                  <span class="dirty m-enter">{{ 'tenants.logoSaveHint' | t }}</span>
                }
                <button mat-flat-button type="submit" [disabled]="busy()">
                  {{ 'common.save' | t }}
                </button>
              </div>
            </div>
            <aside class="preview">
              <p class="m-eyebrow">{{ 'tenants.preview' | t }}</p>
              <p class="hd-muted hint">{{ 'tenants.previewHint' | t }}</p>
              <hd-brand-preview
                [name]="bv().name || t.name"
                [primary]="bv().primary"
                [accent]="bv().accent"
                [logo]="bv().logo"
                [logoDark]="bv().logoDark"
              />
            </aside>
          </form>
        </section>

        <div class="grid">
          <section class="hd-card" [mReveal]="6">
            <h2 class="hd-card-title">{{ 'reports.matrix' | t }}</h2>
            <p class="hd-muted lead">{{ 'tenants.channelsLead' | t }}</p>
            <div class="toggles">
              <div class="toggle">
                <mat-icon aria-hidden="true">language</mat-icon>
                <mat-slide-toggle
                  [checked]="t.channels.website"
                  (change)="setChannel('website', $event.checked)"
                  >{{ 'tenants.website' | t }}</mat-slide-toggle
                >
              </div>
              <div class="toggle">
                <mat-icon aria-hidden="true">dashboard</mat-icon>
                <mat-slide-toggle
                  [checked]="t.channels.admin"
                  (change)="setChannel('admin', $event.checked)"
                  >{{ 'tenants.admin' | t }}</mat-slide-toggle
                >
              </div>
              <div class="toggle">
                <mat-icon aria-hidden="true">smartphone</mat-icon>
                <mat-slide-toggle
                  [checked]="t.channels.mobile"
                  (change)="setChannel('mobile', $event.checked)"
                  >{{ 'tenants.mobile' | t }}</mat-slide-toggle
                >
              </div>
            </div>
            <div class="status-row">
              <span class="hd-muted">{{ 'tenants.status' | t }}</span>
              <button
                mat-stroked-button
                [class.warn-btn]="t.status === 'active'"
                [disabled]="busy()"
                (click)="toggleStatus()"
              >
                <mat-icon>{{ t.status === 'active' ? 'pause_circle' : 'play_circle' }}</mat-icon>
                {{ t.status === 'active' ? ('tenants.suspend' | t) : ('tenants.activate' | t) }}
              </button>
            </div>
          </section>

          <section class="hd-card" [mReveal]="7">
            <h2 class="hd-card-title">{{ 'tenants.staff' | t }}</h2>
            @for (s of t.staff || []; track s._id) {
              <div class="staff">
                <span class="avatar" aria-hidden="true">{{ s.name.charAt(0) }}</span>
                <div class="who">
                  <strong>{{ s.name }}</strong>
                  <span>{{ s.email }} · {{ s.role }}</span>
                  <span class="hd-pill" [class.on]="s.totpEnabled" [class.off]="!s.totpEnabled"
                    >2FA {{ s.totpEnabled ? ('common.enabled' | t) : ('common.disabled' | t) }}</span
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
              <p class="hd-muted">{{ 'common.empty' | t }}</p>
            }
          </section>
        </div>

        <section class="hd-card" [mReveal]="7">
          <h2 class="hd-card-title">{{ 'tenants.domains' | t }}</h2>
          <p class="hd-muted lead">{{ 'tenants.domainsHint' | t }}</p>
          @for (d of domains(); track $index; let i = $index) {
            <div class="domain-row">
              <mat-form-field>
                <mat-label>{{ 'tenants.host' | t }}</mat-label>
                <input
                  matInput
                  [value]="d.host"
                  (input)="patchDomain(i, 'host', $any($event.target).value)"
                  placeholder="shop.example.com"
                />
              </mat-form-field>
              <mat-form-field>
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
                class="del"
                (click)="removeDomain(i)"
                [attr.aria-label]="'common.delete' | t"
              >
                <mat-icon>delete_outline</mat-icon>
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
      } @else if (error()) {
        <hd-state [error]="error()" (retry)="retry()" />
      } @else {
        <div class="identity" aria-busy="true">
          <span class="hd-sk" style="width: 72px; height: 72px; border-radius: 20px"></span>
          <div class="id" style="display: grid; gap: 10px">
            <span class="hd-sk" style="height: 12px; width: 120px"></span>
            <span class="hd-sk" style="height: 32px; width: 240px"></span>
          </div>
        </div>
        <div class="kpis">
          @for (i of skeleton; track i) {
            <div class="hd-card"><span class="hd-sk" style="height: 62px"></span></div>
          }
        </div>
        <div class="hd-card"><span class="hd-sk" style="height: 320px"></span></div>
      }
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
      border-radius: var(--m-r-xs);
    }
    .back:hover {
      color: var(--m-ink);
    }
    .back mat-icon {
      font-size: 18px;
      width: 18px;
      height: 18px;
    }
    :host-context([dir='rtl']) .flip {
      transform: scaleX(-1);
    }
    .identity {
      display: flex;
      align-items: center;
      gap: 20px;
      margin: 8px 0 28px;
    }
    .badge {
      display: grid;
      place-items: center;
      width: 76px;
      height: 76px;
      flex: none;
      border-radius: var(--m-r-lg);
      box-shadow: var(--m-shadow-1), inset 0 -3px 0 var(--m-accent);
      overflow: hidden;
    }
    .badge img {
      max-width: 72%;
      max-height: 60%;
      object-fit: contain;
    }
    .mono {
      font-family: var(--m-font-display);
      font-size: 32px;
      font-weight: 600;
    }
    .id {
      flex: 1;
      min-width: 0;
    }
    .id .m-rule {
      width: 72px;
      margin-top: 12px;
    }
    .status {
      align-self: flex-start;
      margin-top: 8px;
    }
    .kpis {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 16px;
      margin-bottom: 16px;
    }
    .brand {
      margin-bottom: 16px;
    }
    .brand-grid {
      display: grid;
      grid-template-columns: minmax(0, 1.25fr) minmax(0, 1fr);
      gap: 32px;
      align-items: start;
    }
    .fields {
      display: grid;
      gap: 4px;
    }
    .row2 {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px 16px;
      margin-bottom: 16px;
    }
    .sub {
      margin: 0 0 10px;
      font-size: 13px;
      font-weight: 600;
    }
    .colors {
      margin-bottom: 20px;
    }
    .color {
      display: flex;
      align-items: center;
      gap: 14px;
      min-height: 64px;
      padding: 10px 14px;
      box-sizing: border-box;
      border-radius: var(--m-r-md);
      background: var(--m-surface-2);
      cursor: pointer;
    }
    .swatch {
      position: relative;
      width: 44px;
      height: 44px;
      flex: none;
      border-radius: 50%;
      box-shadow:
        0 0 0 3px var(--m-surface),
        0 0 0 4px var(--m-line);
    }
    .swatch input {
      position: absolute;
      inset: 0;
      width: 100%;
      height: 100%;
      opacity: 0;
      cursor: pointer;
      border: 0;
      padding: 0;
    }
    .color:focus-within .swatch {
      box-shadow:
        0 0 0 3px var(--m-surface),
        0 0 0 5px var(--m-accent);
    }
    .color-copy {
      display: grid;
      font-size: 13px;
      color: var(--m-ink-muted);
    }
    .color-copy code {
      font-size: 13px;
      color: var(--m-ink);
      font-weight: 600;
      text-transform: uppercase;
    }
    .logos {
      gap: 16px;
    }
    .actions {
      display: flex;
      align-items: center;
      justify-content: flex-end;
      flex-wrap: wrap;
      gap: 12px;
      margin-top: 12px;
    }
    .dirty {
      color: var(--m-accent-ink);
      font-size: 12px;
      font-weight: 600;
    }
    .preview {
      position: sticky;
      top: 88px;
      display: grid;
      gap: 0;
      padding: 20px;
      border-radius: var(--m-r-lg);
      background: var(--m-surface-2);
    }
    .preview .m-eyebrow {
      margin: 0;
    }
    .hint {
      margin: 4px 0 16px;
      font-size: 13px;
    }
    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
      margin-bottom: 16px;
    }
    .lead {
      margin: -8px 0 16px;
      font-size: 13px;
    }
    .toggles {
      display: grid;
      gap: 4px;
      margin-bottom: 16px;
    }
    .toggle {
      display: flex;
      align-items: center;
      gap: 12px;
      min-height: 52px;
      padding: 0 14px;
      border-radius: var(--m-r-sm);
      background: var(--m-surface-2);
    }
    .toggle mat-icon {
      color: var(--m-accent-ink);
      font-size: 20px;
      width: 20px;
      height: 20px;
    }
    .toggle mat-slide-toggle {
      flex: 1;
    }
    .status-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 12px;
      padding-top: 16px;
      border-top: 1px solid var(--m-line);
      font-size: 13px;
    }
    .warn-btn {
      --mat-button-outlined-label-text-color: var(--m-danger);
      --mat-button-outlined-outline-color: color-mix(in srgb, var(--m-danger) 35%, transparent);
    }
    .staff {
      display: flex;
      align-items: center;
      gap: 14px;
      padding: 14px 0;
      border-top: 1px solid var(--m-line);
    }
    .staff:first-of-type {
      border-top: 0;
      padding-top: 0;
    }
    .avatar {
      display: grid;
      place-items: center;
      width: 40px;
      height: 40px;
      flex: none;
      border-radius: 50%;
      border: 1px solid var(--m-accent);
      color: var(--m-accent-ink);
      font-family: var(--m-font-display);
      font-weight: 600;
    }
    .who {
      flex: 1;
      min-width: 0;
      display: grid;
      justify-items: start;
      gap: 4px;
    }
    .who > span:not(.hd-pill) {
      color: var(--m-ink-muted);
      font-size: 13px;
      overflow-wrap: anywhere;
    }
    .domain-row {
      display: grid;
      grid-template-columns: 1.6fr 1fr 48px;
      gap: 0 12px;
      margin-bottom: 12px;
      align-items: start;
    }
    .del {
      margin-top: 4px;
      color: var(--m-ink-muted);
    }
    .del:hover {
      color: var(--m-danger);
    }
    .row-actions {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      justify-content: flex-end;
    }
    @media (max-width: 1279.98px) {
      .grid {
        grid-template-columns: 1fr;
      }
      .brand-grid {
        grid-template-columns: 1fr;
      }
      .preview {
        position: static;
      }
    }
    @media (max-width: 899.98px) {
      .grid {
        grid-template-columns: 1fr;
      }
      .kpis {
        grid-template-columns: 1fr 1fr;
      }
    }
    @media (max-width: 599.98px) {
      .row2,
      .domain-row {
        grid-template-columns: 1fr;
      }
      .domain-row {
        padding-bottom: 12px;
        margin-bottom: 12px;
        border-bottom: 1px solid var(--m-line);
      }
      .del {
        justify-self: end;
        margin-top: -12px;
      }
      .identity {
        flex-wrap: wrap;
        gap: 16px;
      }
      .badge {
        width: 60px;
        height: 60px;
      }
      .staff {
        flex-wrap: wrap;
      }
      .staff button {
        margin-inline-start: 54px;
      }
      .brand {
        padding: 18px;
      }
      .preview {
        padding: 14px;
        margin-inline: -4px;
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
    logo: [''],
    logoDark: [''],
  });
  /** Live brand form values for the preview (visual only). */
  readonly bv = toSignal(
    this.brand.valueChanges.pipe(
      startWith(null),
      map(() => this.brand.getRawValue()),
    ),
    { initialValue: this.brand.getRawValue() },
  );
  readonly onPrimary = computed(() => onColor(this.bv().primary));
  /** Header badge sits on the primary colour: prefer the dark logo on a dark fill. */
  readonly badgeLogo = computed(() => {
    const v = this.bv();
    return this.onPrimary() === '#ffffff' ? v.logoDark || v.logo : v.logo || v.logoDark;
  });
  readonly skeleton = [0, 1, 2, 3];

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
          logo: res.data.branding?.logo || '',
          logoDark: res.data.branding?.logoDark || '',
        });
        this.brand.markAsPristine();
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

  setLogo(key: 'logo' | 'logoDark', url: string): void {
    this.brand.controls[key].setValue(url);
    this.brand.markAsDirty();
  }

  retry(): void {
    this.error.set(null);
    this.reload();
  }

  saveBrand(): void {
    const v = this.brand.getRawValue();
    this.busy.set(true);
    this.api
      .patch(this.id(), {
        currency: v.currency,
        branding: {
          name: v.name,
          primary: v.primary,
          accent: v.accent,
          logo: v.logo,
          logoDark: v.logoDark,
        },
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
