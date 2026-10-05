import { Component, inject, Input, OnInit, signal } from '@angular/core';
import { FormArray, FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatIconModule } from '@angular/material/icon';
import { AppConfigApi } from '../../core/api/app-config.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { AppConfig, OnboardingSlide } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { ImageUploader } from '../../shared/image-uploader';
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
    MatSelectModule,
    MatIconModule,
    TranslatePipe,
    AsyncState,
    ImageUploader,
  ],
  templateUrl: './app-config-page.html',
  styleUrl: './app-config-page.scss',
})
export class AppConfigPage implements OnInit {
  private readonly api = inject(AppConfigApi);
  private readonly fb = inject(FormBuilder);
  private readonly ui = inject(UiService);
  readonly i18n = inject(I18nService);

  @Input() section: 'all' | 'support' | 'upgrade' | 'onboarding' = 'all';
  @Input() embedded = false;

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
    onboarding: this.fb.array<FormGroup>([]),
    supportEmail: [''],
    supportPhone: [''],
    deliveryFee: [0],
  });

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

  show(part: 'support' | 'upgrade' | 'onboarding'): boolean {
    return this.section === 'all' || this.section === part;
  }

  forcePreview(platform: 'android' | 'ios'): string {
    const v = this.form.getRawValue();
    if (platform === 'android') {
      return this.i18n.lang() === 'ar' ? v.androidMsgAr || v.androidMsgEn : v.androidMsgEn || v.androidMsgAr;
    }
    return this.i18n.lang() === 'ar' ? v.iosMsgAr || v.iosMsgEn : v.iosMsgEn || v.iosMsgAr;
  }

  addOnboarding(): void {
    this.onboarding.push(this.onboardingGroup());
  }

  removeOnboarding(index: number): void {
    this.onboarding.removeAt(index);
  }

  setImage(group: FormGroup, urls: string[]): void {
    group.patchValue({ image: urls[0] ?? '' });
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
      onboarding: v.onboarding.map((s) => ({
        image: String(s['image'] ?? ''),
        title: { en: String(s['titleEn'] ?? ''), ar: String(s['titleAr'] ?? '') },
        body: { en: String(s['bodyEn'] ?? ''), ar: String(s['bodyAr'] ?? '') },
      })),
      settings: {
        supportEmail: v.supportEmail,
        supportPhone: v.supportPhone,
        deliveryFee: Number(v.deliveryFee) || 0,
      },
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
      supportEmail: String(cfg.settings?.['supportEmail'] ?? ''),
      supportPhone: String(cfg.settings?.['supportPhone'] ?? ''),
      deliveryFee: Number(cfg.settings?.['deliveryFee'] ?? 0),
    });
    this.onboarding.clear();
    (cfg.onboarding ?? []).forEach((s) => this.onboarding.push(this.onboardingGroup(s)));
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
