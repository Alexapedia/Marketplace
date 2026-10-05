import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { PageEvent, MatPaginatorModule } from '@angular/material/paginator';
import { MAT_DIALOG_DATA, MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatTableModule } from '@angular/material/table';
import { AdsApi } from '../../core/api/ads.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { Banner, entityId, loc, PageMeta } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { ImageUploader } from '../../shared/image-uploader';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-ad-dialog',
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatSlideToggleModule,
    MatButtonModule,
    TranslatePipe,
    ImageUploader,
  ],
  template: `
    <h2 mat-dialog-title>{{ (data.ad ? 'common.edit' : 'ads.create') | t }}</h2>
    <mat-dialog-content [formGroup]="form" class="dlg">
      <div class="wide">
        <div class="lbl">{{ 'ads.image' | t }}</div>
        <app-image-uploader
          [images]="form.controls.image.value ? [form.controls.image.value] : []"
          [multiple]="false"
          (imagesChange)="form.patchValue({  image: $event[0]   })"
        />
      </div>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'ads.titleEn' | t }}</mat-label>
        <input matInput formControlName="titleEn" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'ads.titleAr' | t }}</mat-label>
        <input matInput formControlName="titleAr" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'ads.subtitleEn' | t }}</mat-label>
        <input matInput formControlName="subtitleEn" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'ads.subtitleAr' | t }}</mat-label>
        <input matInput formControlName="subtitleAr" />
      </mat-form-field>
      <mat-form-field appearance="outline" class="wide">
        <mat-label>{{ 'ads.link' | t }}</mat-label>
        <input matInput formControlName="link" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'ads.placement' | t }}</mat-label>
        <mat-select formControlName="placement">
          <mat-option value="home">{{ 'ads.placementHome' | t }}</mat-option>
          <mat-option value="products">{{ 'ads.placementProducts' | t }}</mat-option>
          <mat-option value="both">{{ 'ads.placementBoth' | t }}</mat-option>
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'ads.sortOrder' | t }}</mat-label>
        <input matInput type="number" formControlName="sortOrder" />
      </mat-form-field>
      <mat-slide-toggle formControlName="active">{{ 'ads.active' | t }}</mat-slide-toggle>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>{{ 'common.cancel' | t }}</button>
      <button mat-flat-button (click)="save()" [disabled]="saving()">{{ 'common.save' | t }}</button>
    </mat-dialog-actions>
  `,
  styles: `
    .dlg { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; min-width: min(640px, 90vw); padding-top: 8px; }
    .wide { grid-column: 1 / -1; }
    .lbl { font-size: 12px; font-weight: 600; margin-bottom: 6px; }
  `,
})
export class AdDialog {
  private readonly fb = inject(FormBuilder);
  private readonly api = inject(AdsApi);
  private readonly ui = inject(UiService);
  private readonly i18n = inject(I18nService);
  private readonly ref = inject(MatDialogRef<AdDialog>);
  readonly data = inject<{ ad?: Banner }>(MAT_DIALOG_DATA);
  readonly saving = signal(false);

  readonly form = this.fb.nonNullable.group({
    image: [this.data.ad?.image ?? '', Validators.required],
    titleEn: [this.titleOf('en')],
    titleAr: [this.titleOf('ar')],
    subtitleEn: [this.subOf('en')],
    subtitleAr: [this.subOf('ar')],
    link: [this.data.ad?.link ?? ''],
    placement: [this.data.ad?.placement ?? 'home'],
    sortOrder: [this.data.ad?.sortOrder ?? 0],
    active: [this.data.ad?.active !== false],
  });

  private titleOf(lang: 'en' | 'ar'): string {
    const t = this.data.ad?.title;
    return typeof t === 'string' ? t : t?.[lang] ?? '';
  }

  private subOf(lang: 'en' | 'ar'): string {
    const t = this.data.ad?.subtitle;
    return typeof t === 'string' ? t : t?.[lang] ?? '';
  }

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    const v = this.form.getRawValue();
    const body = {
      image: v.image,
      title: { en: v.titleEn, ar: v.titleAr },
      subtitle: { en: v.subtitleEn, ar: v.subtitleAr },
      link: v.link,
      placement: v.placement,
      sortOrder: Number(v.sortOrder) || 0,
      active: v.active,
    };
    this.saving.set(true);
    const id = entityId(this.data.ad);
    const req = id ? this.api.update(id, body) : this.api.create(body);
    req.subscribe({
      next: () => {
        this.saving.set(false);
        this.ui.success(this.i18n.t('common.save'));
        this.ref.close(true);
      },
      error: (err: unknown) => {
        this.saving.set(false);
        this.ui.error(errMessage(err));
      },
    });
  }
}

@Component({
  selector: 'app-ads-page',
  imports: [
    MatTableModule,
    MatPaginatorModule,
    MatButtonModule,
    MatIconModule,
    MatFormFieldModule,
    MatSelectModule,
    TranslatePipe,
    AsyncState,
  ],
  templateUrl: './ads-page.html',
  styleUrl: './ads-page.scss',
})
export class AdsPage implements OnInit {
  private readonly api = inject(AdsApi);
  private readonly dialog = inject(MatDialog);
  private readonly ui = inject(UiService);
  private readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly rows = signal<Banner[]>([]);
  readonly meta = signal<PageMeta>({ page: 1, limit: 20, total: 0, totalPages: 0 });
  readonly displayedColumns = ['image', 'title', 'placement', 'sortOrder', 'active', 'actions'];
  readonly loc = loc;
  readonly lang = () => this.i18n.lang();
  readonly placement = signal('');

  ngOnInit(): void {
    this.load();
  }

  load(page = this.meta().page): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list({ page, limit: this.meta().limit, placement: this.placement() || undefined }).subscribe({
      next: (res) => {
        this.rows.set(asList(res.data));
        if (res.meta) this.meta.set(res.meta);
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  page(ev: PageEvent): void {
    this.meta.update((m) => ({ ...m, page: ev.pageIndex + 1, limit: ev.pageSize }));
    this.load(ev.pageIndex + 1);
  }

  open(ad?: Banner): void {
    this.dialog
      .open(AdDialog, { data: { ad }, width: '720px' })
      .afterClosed()
      .subscribe((ok) => {
        if (ok) this.load();
      });
  }

  remove(row: Banner): void {
    if (!confirm(this.i18n.t('common.delete'))) return;
    this.api.remove(entityId(row)).subscribe({
      next: () => this.load(),
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }

  titleOf(row: Banner): string {
    return loc(row.title, this.i18n.lang()) || loc(row.title, 'en') || loc(row.title, 'ar') || '—';
  }

  subtitleOf(row: Banner): string {
    return loc(row.subtitle, this.i18n.lang()) || loc(row.subtitle, 'en') || loc(row.subtitle, 'ar');
  }

  imageSrc(row: Banner): string {
    const value = (row.image || '').trim();
    if (!value) return '';
    if (value.startsWith('http') || value.startsWith('data:') || value.startsWith('/')) {
      return value;
    }
    return `/${value}`;
  }

  placementLabel(row: Banner): string {
    const key =
      row.placement === 'products'
        ? 'ads.placementProducts'
        : row.placement === 'both'
          ? 'ads.placementBoth'
          : 'ads.placementHome';
    return this.i18n.t(key);
  }
}
