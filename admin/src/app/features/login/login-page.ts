import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { AuthService, LoginOutcome } from '../../core/auth/auth.service';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { STAFF_ROLES } from '../../core/models/models';
import { ApiError } from '../../core/api/api-client';
import { StoreConfigService } from '../../core/config/store-config.service';

@Component({
  selector: 'app-login-page',
  imports: [
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatProgressSpinnerModule,
    TranslatePipe,
  ],
  templateUrl: './login-page.html',
  styleUrl: './login-page.scss',
})
export class LoginPage {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  readonly i18n = inject(I18nService);
  readonly store = inject(StoreConfigService);

  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly hide = signal(true);
  readonly step = signal<'creds' | 'setup' | 'verify' | 'backup'>('creds');
  readonly qr = signal<string | null>(null);
  readonly backupCodes = signal<string[]>([]);
  private challengeToken = '';

  readonly form = this.fb.nonNullable.group({
    email: ['admin@placemarket.com', [Validators.required, Validators.email]],
    password: ['Admin@123456', [Validators.required, Validators.minLength(6)]],
    code: [''],
  });

  submit(): void {
    if (this.loading()) return;
    this.error.set(null);
    const step = this.step();
    if (step === 'backup') {
      void this.router.navigate(['/dashboard']);
      return;
    }
    if (step === 'creds') {
      if (this.form.controls.email.invalid || this.form.controls.password.invalid) {
        this.form.markAllAsTouched();
        return;
      }
      this.loading.set(true);
      const { email, password } = this.form.getRawValue();
      this.auth.login(email, password).subscribe({
        next: (out) => this.handle(out),
        error: (err: unknown) => this.fail(err),
      });
      return;
    }
    const code = this.form.controls.code.value.trim();
    if (code.length < 6) {
      this.error.set(this.i18n.t('login.error'));
      return;
    }
    this.loading.set(true);
    const req =
      step === 'setup'
        ? this.auth.setup2fa(this.challengeToken, code)
        : this.auth.verify2fa(this.challengeToken, code);
    req.subscribe({
      next: (out) => this.handle(out),
      error: (err: unknown) => this.fail(err),
    });
  }

  private handle(out: LoginOutcome): void {
    this.loading.set(false);
    if (out.kind === 'setup') {
      this.challengeToken = out.challengeToken;
      this.qr.set(out.qr || null);
      this.step.set('setup');
      return;
    }
    if (out.kind === '2fa') {
      this.challengeToken = out.challengeToken;
      this.step.set('verify');
      return;
    }
    const staff =
      out.user.role !== 'customer' && (STAFF_ROLES as string[]).includes(out.user.role);
    if (!staff) {
      this.auth.logout(false);
      this.error.set(this.i18n.t('login.notStaff'));
      return;
    }
    if (out.backupCodes?.length) {
      this.backupCodes.set(out.backupCodes);
      this.step.set('backup');
      return;
    }
    void this.router.navigate(['/dashboard']);
  }

  private fail(err: unknown): void {
    this.loading.set(false);
    if (err instanceof ApiError && err.offline) {
      this.error.set(this.i18n.t('login.offline'));
      return;
    }
    this.error.set(err instanceof Error ? err.message : this.i18n.t('login.error'));
  }
}
