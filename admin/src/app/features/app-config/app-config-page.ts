import { Component, inject, OnInit, signal } from '@angular/core';
import { FormArray, FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { AppConfigApi } from '../../core/api/app-config.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { AppConfig, Banner, OnboardingSlide } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-app-config-page',
  imports: [
    ReactiveFormsModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSlideToggleModule,
    MatCheckboxModule,
    TranslatePipe,
    AsyncState,
  ],
  templateUrl: './app-config-page.html',
  styleUrl: './app-config-page.scss',
})
export class AppConfigPage implements OnInit {
  private readonly api = inject(AppConfigApi);
  private readonly fb = inject(FormBuilder);
  private readonly ui = inject(UiService);
  readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly saving = signal(false);

  readonly form = this.fb.nonNullable.group({
    androidLatest: [''],
    androidMinimum: [''],
    androidForce: [false],
    androidStore: [''],
    androidMsgEn: [''],
    androidMsgAr: [''],
    iosLatest: [''],
    iosMinimum: [''],
    iosForce: [false],
    iosStore: [''],
    iosMsgEn: [''],
    iosMsgAr: [''],
    banners: this.fb.array<FormGroup>([]),
    onboarding: this.fb.array<FormGroup>([]),
  });

  get banners(): FormArray<FormGroup> {
    return this.form.controls.banners;
  }

  get onboarding(): FormArray<FormGroup> {
    return this.form.controls.onboarding;
  }

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.get().subscribe({
      next: (res) => {
        this.patch(res.data ?? {});
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  addBanner(): void {
    this.banners.push(this.bannerGroup());
  }

  addOnboarding(): void {
    this.onboarding.push(this.onboardingGroup());
  }

  save(): void {
    const v = this.form.getRawValue();
    const payload: AppConfig = {
      version: {
        android: {
          latest: v.androidLatest,
          minimum: v.androidMinimum,
          forceUpdate: v.androidForce,
          storeUrl: v.androidStore,
          message: { en: v.androidMsgEn, ar: v.androidMsgAr },
        },
        ios: {
          latest: v.iosLatest,
          minimum: v.iosMinimum,
          forceUpdate: v.iosForce,
          storeUrl: v.iosStore,
          message: { en: v.iosMsgEn, ar: v.iosMsgAr },
        },
      },
      banners: v.banners.map((b) => ({
        image: String(b['image'] ?? ''),
        link: String(b['link'] ?? ''),
        title: { en: String(b['titleEn'] ?? ''), ar: String(b['titleAr'] ?? '') },
        active: !!b['active'],
      })),
      onboarding: v.onboarding.map((s) => ({
        image: String(s['image'] ?? ''),
        title: { en: String(s['titleEn'] ?? ''), ar: String(s['titleAr'] ?? '') },
        body: { en: String(s['bodyEn'] ?? ''), ar: String(s['bodyAr'] ?? '') },
      })),
    };
    this.saving.set(true);
    this.api.update(payload).subscribe({
      next: () => {
        this.saving.set(false);
        this.ui.success(this.i18n.t('common.save'));
      },
      error: (err: unknown) => {
        this.saving.set(false);
        this.ui.error(errMessage(err));
      },
    });
  }

  private patch(cfg: AppConfig): void {
    const android = cfg.version?.android ?? {};
    const ios = cfg.version?.ios ?? {};
    this.form.patchValue({
      androidLatest: android.latest ?? '',
      androidMinimum: android.minimum ?? '',
      androidForce: !!android.forceUpdate,
      androidStore: android.storeUrl ?? '',
      androidMsgEn: android.message?.en ?? '',
      androidMsgAr: android.message?.ar ?? '',
      iosLatest: ios.latest ?? '',
      iosMinimum: ios.minimum ?? '',
      iosForce: !!ios.forceUpdate,
      iosStore: ios.storeUrl ?? '',
      iosMsgEn: ios.message?.en ?? '',
      iosMsgAr: ios.message?.ar ?? '',
    });
    this.banners.clear();
    (cfg.banners ?? []).forEach((b) => this.banners.push(this.bannerGroup(b)));
    this.onboarding.clear();
    (cfg.onboarding ?? []).forEach((s) => this.onboarding.push(this.onboardingGroup(s)));
  }

  private bannerGroup(b?: Banner): FormGroup {
    const title = typeof b?.title === 'string' ? { en: b.title, ar: b.title } : b?.title;
    return this.fb.nonNullable.group({
      image: [b?.image ?? ''],
      link: [b?.link ?? ''],
      titleEn: [title?.en ?? ''],
      titleAr: [title?.ar ?? ''],
      active: [b?.active ?? true],
    });
  }

  private onboardingGroup(s?: OnboardingSlide): FormGroup {
    const title = typeof s?.title === 'string' ? { en: s.title, ar: s.title } : s?.title;
    const body = typeof s?.body === 'string' ? { en: s.body, ar: s.body } : s?.body;
    return this.fb.nonNullable.group({
      image: [s?.image ?? ''],
      titleEn: [title?.en ?? ''],
      titleAr: [title?.ar ?? ''],
      bodyEn: [body?.en ?? ''],
      bodyAr: [body?.ar ?? ''],
    });
  }
}
