import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { CategoriesApi } from '../../core/api/categories.api';
import { CustomFieldsApi } from '../../core/api/custom-fields.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { LocPipe, TranslatePipe } from '../../core/i18n/translate.pipe';
import {
  Category,
  CUSTOM_FIELD_TYPES,
  CustomField,
  entityId,
  loc,
  localizedOf,
} from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-field-dialog',
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatCheckboxModule, MatButtonModule, TranslatePipe],
  template: `
    <h2 mat-dialog-title>{{ (data.field ? 'common.edit' : 'fields.create') | t }}</h2>
    <mat-dialog-content [formGroup]="form" class="dlg">
      <mat-form-field appearance="outline"><mat-label>{{ 'fields.labelsEn' | t }}</mat-label><input matInput formControlName="en" /></mat-form-field>
      <mat-form-field appearance="outline"><mat-label>{{ 'fields.labelsAr' | t }}</mat-label><input matInput formControlName="ar" /></mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'common.category' | t }}</mat-label>
        <mat-select formControlName="categoryId">
          @for (c of data.categories; track id(c)) {
            <mat-option [value]="id(c)">{{ locName(c) }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'fields.type' | t }}</mat-label>
        <mat-select formControlName="fieldType">
          @for (t of types; track t) { <mat-option [value]="t">{{ t }}</mat-option> }
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline" class="wide"><mat-label>{{ 'fields.options' | t }}</mat-label><input matInput formControlName="options" /></mat-form-field>
      <mat-checkbox formControlName="required">{{ 'common.required' | t }}</mat-checkbox>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>{{ 'common.cancel' | t }}</button>
      <button mat-flat-button (click)="save()">{{ 'common.save' | t }}</button>
    </mat-dialog-actions>
  `,
  styles: `.dlg{display:grid;grid-template-columns:1fr 1fr;gap:8px 12px;min-width:min(560px,90vw)}.wide{grid-column:1/-1}`,
})
export class FieldDialog {
  readonly data = inject<{ field?: CustomField; categories: Category[] }>(MAT_DIALOG_DATA);
  private readonly ref = inject(MatDialogRef<FieldDialog, unknown>);
  private readonly fb = inject(FormBuilder);
  private readonly i18n = inject(I18nService);
  readonly types = CUSTOM_FIELD_TYPES;
  readonly id = entityId;

  readonly form = this.fb.nonNullable.group({
    en: [loc(this.data.field?.label ?? this.data.field?.labels, 'en'), Validators.required],
    ar: [loc(this.data.field?.label ?? this.data.field?.labels, 'ar'), Validators.required],
    categoryId: [this.data.field?.categoryId ?? '', Validators.required],
    fieldType: [this.data.field?.fieldType ?? 'text'],
    options: [(this.data.field?.options ?? []).join(', ')],
    required: [!!this.data.field?.required],
  });

  locName(c: Category): string {
    return loc(localizedOf(c), this.i18n.lang());
  }

  save(): void {
    const v = this.form.getRawValue();
    const labels = { en: v.en, ar: v.ar };
    this.ref.close({
      labels,
      label: labels,
      categoryId: v.categoryId,
      fieldType: v.fieldType,
      required: v.required,
      options: v.options.split(',').map((s) => s.trim()).filter(Boolean),
    });
  }
}

@Component({
  selector: 'app-custom-fields-page',
  imports: [MatTableModule, MatButtonModule, MatIconModule, MatFormFieldModule, MatSelectModule, TranslatePipe, LocPipe, AsyncState],
  template: `
    <div class="head">
      <h2>{{ 'fields.title' | t }}</h2>
      <button mat-flat-button (click)="open()"><mat-icon>add</mat-icon>{{ 'fields.create' | t }}</button>
    </div>
    <mat-form-field appearance="outline">
      <mat-label>{{ 'common.category' | t }}</mat-label>
      <mat-select [value]="categoryId()" (selectionChange)="filter($event.value)">
        <mat-option value="">{{ 'common.all' | t }}</mat-option>
        @for (c of categories(); track entityId(c)) {
          <mat-option [value]="entityId(c)">{{ localizedOf(c) | loc }}</mat-option>
        }
      </mat-select>
    </mat-form-field>
    <app-async-state [loading]="loading()" [error]="error()" [empty]="!loading() && !error() && rows().length === 0" (retry)="load()" />
    @if (!loading() && !error() && rows().length) {
      <table mat-table [dataSource]="rows()" class="full">
        <ng-container matColumnDef="label">
          <th mat-header-cell *matHeaderCellDef>{{ 'common.name' | t }}</th>
          <td mat-cell *matCellDef="let row">{{ (row.label || row.labels) | loc }}</td>
        </ng-container>
        <ng-container matColumnDef="fieldType">
          <th mat-header-cell *matHeaderCellDef>{{ 'fields.type' | t }}</th>
          <td mat-cell *matCellDef="let row">{{ row.fieldType }}</td>
        </ng-container>
        <ng-container matColumnDef="required">
          <th mat-header-cell *matHeaderCellDef>{{ 'common.required' | t }}</th>
          <td mat-cell *matCellDef="let row">{{ row.required ? ('common.yes' | t) : ('common.no' | t) }}</td>
        </ng-container>
        <ng-container matColumnDef="actions">
          <th mat-header-cell *matHeaderCellDef>{{ 'common.actions' | t }}</th>
          <td mat-cell *matCellDef="let row">
            <button mat-icon-button (click)="open(row)"><mat-icon>edit</mat-icon></button>
            <button mat-icon-button (click)="remove(row)"><mat-icon>delete</mat-icon></button>
          </td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let row; columns: cols"></tr>
      </table>
    }
  `,
  styles: `.head{display:flex;justify-content:space-between;align-items:center}h2{margin:0}.full{width:100%}`,
})
export class CustomFieldsPage implements OnInit {
  private readonly api = inject(CustomFieldsApi);
  private readonly categoriesApi = inject(CategoriesApi);
  private readonly dialog = inject(MatDialog);
  private readonly ui = inject(UiService);
  readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly rows = signal<CustomField[]>([]);
  readonly categories = signal<Category[]>([]);
  readonly categoryId = signal('');
  readonly cols = ['label', 'fieldType', 'required', 'actions'];
  readonly entityId = entityId;
  readonly localizedOf = localizedOf;

  ngOnInit(): void {
    this.categoriesApi.list({ limit: 200 }).subscribe({ next: (res) => this.categories.set(asList(res.data)) });
    this.load();
  }

  filter(id: string): void {
    this.categoryId.set(id);
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list({ categoryId: this.categoryId() || undefined, limit: 200 }).subscribe({
      next: (res) => {
        this.rows.set(asList(res.data));
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  open(field?: CustomField): void {
    const ref = this.dialog.open(FieldDialog, {
      data: { field, categories: this.categories() },
      width: '640px',
    });
    ref.afterClosed().subscribe((body: unknown) => {
      if (!body) {
        return;
      }
      const req = field ? this.api.update(entityId(field), body) : this.api.create(body);
      req.subscribe({
        next: () => {
          this.ui.success(this.i18n.t('common.save'));
          this.load();
        },
        error: (err: unknown) => this.ui.error(errMessage(err)),
      });
    });
  }

  remove(field: CustomField): void {
    this.api.remove(entityId(field)).subscribe({
      next: () => {
        this.ui.success(this.i18n.t('common.delete'));
        this.load();
      },
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }
}
