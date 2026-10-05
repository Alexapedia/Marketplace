import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { PlatformApi } from '../../core/api/platform.api';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-tenant-create-page',
  imports: [ReactiveFormsModule, MatFormFieldModule, MatInputModule, MatButtonModule, TranslatePipe, RouterLink],
  template: `
    <div class="hd-page">
      <a class="back" routerLink="/tenants">{{ 'common.back' | t }}</a>
      <p class="hd-kicker">{{ 'nav.control' | t }}</p>
      <h2 class="hd-h">{{ 'tenants.new' | t }}</h2>
      <form [formGroup]="form" (ngSubmit)="submit()" class="hd-card form">
        <mat-form-field><mat-label>{{ 'tenants.slug' | t }}</mat-label><input matInput formControlName="slug" /></mat-form-field>
        <mat-form-field><mat-label>{{ 'tenants.name' | t }}</mat-label><input matInput formControlName="name" /></mat-form-field>
        <mat-form-field><mat-label>{{ 'tenants.adminEmail' | t }}</mat-label><input matInput type="email" formControlName="adminEmail" /></mat-form-field>
        <mat-form-field><mat-label>{{ 'tenants.adminPassword' | t }}</mat-label><input matInput type="password" formControlName="adminPassword" /></mat-form-field>
        <mat-form-field><mat-label>{{ 'tenants.websiteHost' | t }}</mat-label><input matInput formControlName="websiteHost" /></mat-form-field>
        <mat-form-field><mat-label>{{ 'tenants.adminHost' | t }}</mat-label><input matInput formControlName="adminHost" /></mat-form-field>
        <mat-form-field><mat-label>{{ 'tenants.currency' | t }}</mat-label><input matInput formControlName="currency" /></mat-form-field>
        <div class="colors">
          <mat-form-field><mat-label>{{ 'tenants.primary' | t }}</mat-label><input matInput formControlName="primary" /></mat-form-field>
          <mat-form-field><mat-label>{{ 'tenants.accent' | t }}</mat-label><input matInput formControlName="accent" /></mat-form-field>
        </div>
        @if (error()) { <p class="err">{{ error() }}</p> }
        <button mat-flat-button type="submit" [disabled]="loading()">{{ 'common.create' | t }}</button>
      </form>
    </div>
  `,
  styles: `
    .back { color: var(--zz-muted); text-decoration: none; font-size: 13px; font-weight: 700; }
    .hd-kicker { margin-top: 10px; }
    .form { display: grid; grid-template-columns: 1fr 1fr; gap: 8px 16px; max-width: 840px; margin-top: 16px; }
    .colors { display: contents; }
    button { justify-self: start; margin-top: 8px; }
    .err { color: #9f1239; grid-column: 1 / -1; }
    @media (max-width: 720px) { .form { grid-template-columns: 1fr; } }
  `,
})
export class TenantCreatePage {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(PlatformApi);
  private readonly router = inject(Router);
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
