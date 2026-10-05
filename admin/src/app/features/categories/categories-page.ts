import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import {
  MAT_DIALOG_DATA,
  MatDialog,
  MatDialogModule,
  MatDialogRef,
} from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatChipsModule } from '@angular/material/chips';
import { MatTableModule } from '@angular/material/table';
import { CategoriesApi } from '../../core/api/categories.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { LocPipe, TranslatePipe } from '../../core/i18n/translate.pipe';
import { Category, entityId, loc, localizedOf } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { ImageUploader } from '../../shared/image-uploader';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-category-dialog',
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    TranslatePipe,
    ImageUploader,
  ],
  template: `
    <h2 mat-dialog-title>{{ (data.category ? 'common.edit' : 'categories.create') | t }}</h2>
    <mat-dialog-content [formGroup]="form" class="dlg">
      <mat-form-field appearance="outline"
        ><mat-label>{{ 'common.nameEn' | t }}</mat-label
        ><input matInput formControlName="nameEn"
      /></mat-form-field>
      <mat-form-field appearance="outline"
        ><mat-label>{{ 'common.nameAr' | t }}</mat-label
        ><input matInput formControlName="nameAr"
      /></mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'categories.parent' | t }}</mat-label>
        <mat-select formControlName="parentId">
          <mat-option [value]="''">—</mat-option>
          @for (c of data.categories; track id(c)) {
            <mat-option [value]="id(c)">{{ locName(c) }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'categories.type' | t }}</mat-label>
        <mat-select formControlName="type">
          <mat-option value="standard">standard</mat-option>
          <mat-option value="custom">custom</mat-option>
          <mat-option value="both">both</mat-option>
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline"
        ><mat-label>{{ 'categories.sortOrder' | t }}</mat-label
        ><input matInput type="number" formControlName="sortOrder"
      /></mat-form-field>
      <mat-form-field appearance="outline"
        ><mat-label>{{ 'common.status' | t }}</mat-label>
        <mat-select formControlName="status">
          <mat-option value="published">published</mat-option>
          <mat-option value="unpublished">unpublished</mat-option>
        </mat-select>
      </mat-form-field>
      <div class="wide">
        <div class="lbl">{{ 'categories.image' | t }}</div>
        <app-image-uploader
          [images]="form.controls.image.value ? [form.controls.image.value] : []"
          [multiple]="false"
          (imagesChange)="form.patchValue({ image: $event[0] || '' })"
        />
      </div>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>{{ 'common.cancel' | t }}</button>
      <button mat-flat-button (click)="save()">{{ 'common.save' | t }}</button>
    </mat-dialog-actions>
  `,
  styles: `
    .dlg {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px 14px;
      min-width: min(560px, 92vw);
      padding-top: 8px;
    }
    .wide {
      grid-column: 1/-1;
    }
    .lbl {
      font-size: 12px;
      font-weight: 700;
      color: #5c678c;
      margin-bottom: 8px;
    }
  `,
})
export class CategoryDialog {
  readonly data = inject<{ category?: Category; categories: Category[] }>(MAT_DIALOG_DATA);
  private readonly ref = inject(MatDialogRef<CategoryDialog, unknown>);
  private readonly fb = inject(FormBuilder);
  private readonly i18n = inject(I18nService);
  readonly id = entityId;

  readonly form = this.fb.nonNullable.group({
    nameEn: [loc(localizedOf(this.data.category ?? {}), 'en'), Validators.required],
    nameAr: [loc(localizedOf(this.data.category ?? {}), 'ar'), Validators.required],
    parentId: [typeof this.data.category?.parentId === 'string' ? this.data.category.parentId : ''],
    type: [this.data.category?.type ?? 'standard'],
    sortOrder: [this.data.category?.sortOrder ?? 0],
    status: [this.data.category?.status ?? 'published'],
    image: [this.data.category?.image ?? ''],
  });

  locName(c: Category): string {
    return loc(localizedOf(c), this.i18n.lang());
  }

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    const v = this.form.getRawValue();
    const name = { en: v.nameEn, ar: v.nameAr };
    this.ref.close({
      name,
      names: name,
      parentId: v.parentId || null,
      type: v.type,
      sortOrder: Number(v.sortOrder),
      status: v.status,
      image: v.image || undefined,
    });
  }
}

@Component({
  selector: 'app-categories-page',
  imports: [
    MatTableModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    TranslatePipe,
    LocPipe,
    AsyncState,
  ],
  template: `
    <div class="head">
      <h2 class="page-h">{{ 'categories.title' | t }}</h2>
      <button mat-flat-button (click)="open()">
        <mat-icon>add</mat-icon>{{ 'categories.create' | t }}
      </button>
    </div>
    <div class="filters">
      <mat-form-field appearance="outline">
        <mat-label>{{ 'common.search' | t }}</mat-label>
        <input matInput [value]="search()" (input)="search.set($any($event.target).value)" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'categories.type' | t }}</mat-label>
        <mat-select [value]="type()" (selectionChange)="type.set($event.value)">
          <mat-option value="">{{ 'common.all' | t }}</mat-option>
          <mat-option value="standard">standard</mat-option>
          <mat-option value="custom">custom</mat-option>
          <mat-option value="both">both</mat-option>
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'common.status' | t }}</mat-label>
        <mat-select [value]="status()" (selectionChange)="status.set($event.value)">
          <mat-option value="">{{ 'common.all' | t }}</mat-option>
          <mat-option value="published">published</mat-option>
          <mat-option value="unpublished">unpublished</mat-option>
        </mat-select>
      </mat-form-field>
    </div>
    <app-async-state
      [loading]="loading()"
      [error]="error()"
      [empty]="!loading() && !error() && flat().length === 0"
      (retry)="load()"
    />
    @if (!loading() && !error() && flat().length) {
      <div class="table-wrap">
        <table mat-table [dataSource]="flat()" class="full">
          <ng-container matColumnDef="image">
            <th mat-header-cell *matHeaderCellDef>{{ 'common.image' | t }}</th>
            <td mat-cell *matCellDef="let row" [style.paddingInlineStart.px]="16 + row.depth * 20">
              <img class="thumb" [src]="row.item.image" width="50" height="50" alt="" />
            </td>
          </ng-container>
          <ng-container matColumnDef="name">
            <th mat-header-cell *matHeaderCellDef>{{ 'common.name' | t }}</th>
            <td mat-cell *matCellDef="let row" [style.paddingInlineStart.px]="16 + row.depth * 20">
              {{ localizedOf(row.item) | loc }}
            </td>
          </ng-container>
          <ng-container matColumnDef="type">
            <th mat-header-cell *matHeaderCellDef>{{ 'categories.type' | t }}</th>
            <td mat-cell *matCellDef="let row">{{ row.item.type }}</td>
          </ng-container>
          <ng-container matColumnDef="status">
            <th mat-header-cell *matHeaderCellDef>{{ 'common.status' | t }}</th>
            <td mat-cell *matCellDef="let row">
              <mat-chip [class]="'st-' + row.item.status">{{ row.item.status }}</mat-chip>
            </td>
          </ng-container>
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef>{{ 'common.actions' | t }}</th>
            <td mat-cell *matCellDef="let row">
              <button mat-icon-button (click)="open(row.item)"><mat-icon>edit</mat-icon></button>
              <button mat-icon-button (click)="remove(row.item)">
                <mat-icon>delete</mat-icon>
              </button>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="cols"></tr>
          <tr mat-row *matRowDef="let row; columns: cols"></tr>
        </table>
      </div>
    }
  `,
  styles: `
    .head {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      gap: 12px;
    }
    h2 {
      margin: 0;
    }
    .full {
      width: 100%;
    }
    .filters {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      margin-bottom: 8px;
    }
    .filters mat-form-field {
      width: min(220px, 100%);
    }
    .thumb {
      width: 44px;
      height: 44px;
      object-fit: cover;
      border-radius: 10px;
      background: #eef1f8;
    }
  `,
})
export class CategoriesPage implements OnInit {
  private readonly api = inject(CategoriesApi);
  private readonly dialog = inject(MatDialog);
  private readonly ui = inject(UiService);
  readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly items = signal<Category[]>([]);
  readonly cols = ['image', 'name', 'type', 'status', 'actions'];
  readonly localizedOf = localizedOf;
  readonly search = signal('');
  readonly type = signal('');
  readonly status = signal('');

  ngOnInit(): void {
    this.load();
  }

  flat(): Array<{ item: Category; depth: number }> {
    const out: Array<{ item: Category; depth: number }> = [];
    const walk = (nodes: Category[], depth: number) => {
      for (const n of nodes) {
        out.push({ item: n, depth });
        if (n.children?.length) {
          walk(n.children, depth + 1);
        }
      }
    };
    const roots = this.items().filter((c) => !c.parentId);
    if (roots.length && this.items().some((c) => c.children?.length)) {
      walk(
        this.items().filter((c) => !c.parentId),
        0,
      );
    } else {
      const byParent = new Map<string, Category[]>();
      for (const c of this.items()) {
        const pid = typeof c.parentId === 'string' ? c.parentId : '';
        const list = byParent.get(pid) ?? [];
        list.push(c);
        byParent.set(pid, list);
      }
      const walkId = (pid: string, depth: number) => {
        for (const n of byParent.get(pid) ?? []) {
          out.push({ item: n, depth });
          walkId(entityId(n), depth + 1);
        }
      };
      walkId('', 0);
      if (!out.length) {
        this.items().forEach((item) => out.push({ item, depth: 0 }));
      }
    }
    return out.filter((row) => {
      const q = this.search().trim().toLowerCase();
      const name = loc(localizedOf(row.item), this.i18n.lang()).toLowerCase();
      const typeOk = !this.type() || row.item.type === this.type();
      const statusOk = !this.status() || row.item.status === this.status();
      const searchOk = !q || name.includes(q);
      return typeOk && statusOk && searchOk;
    });
  }

  load(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list({ limit: 200 }).subscribe({
      next: (res) => {
        this.items.set(asList(res.data));
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  open(category?: Category): void {
    const ref = this.dialog.open(CategoryDialog, {
      data: {
        category,
        categories: this.items().filter((c) => entityId(c) !== entityId(category)),
      },
      width: '680px',
      maxWidth: '94vw',
    });
    ref.afterClosed().subscribe((body: unknown) => {
      if (!body) {
        return;
      }
      const req = category ? this.api.update(entityId(category), body) : this.api.create(body);
      req.subscribe({
        next: () => {
          this.ui.success(this.i18n.t('common.save'));
          this.load();
        },
        error: (err: unknown) => this.ui.error(errMessage(err)),
      });
    });
  }

  remove(category: Category): void {
    this.api.remove(entityId(category)).subscribe({
      next: () => {
        this.ui.success(this.i18n.t('common.delete'));
        this.load();
      },
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }
}
