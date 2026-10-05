import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { PageEvent } from '@angular/material/paginator';
import { MAT_DIALOG_DATA, MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatChipsModule } from '@angular/material/chips';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { CategoriesApi } from '../../core/api/categories.api';
import { ProductsApi } from '../../core/api/products.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { LocPipe, TranslatePipe } from '../../core/i18n/translate.pipe';
import {
  Category,
  entityId,
  loc,
  localizedOf,
  PageMeta,
  Product,
} from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { ImageUploader } from '../../shared/image-uploader';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-product-dialog',
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatCheckboxModule,
    MatButtonModule,
    TranslatePipe,
    ImageUploader,
  ],
  template: `
    <h2 mat-dialog-title>{{ (data.product ? 'common.edit' : 'products.create') | t }}</h2>
    <mat-dialog-content [formGroup]="form" class="dlg">
      <mat-form-field appearance="outline">
        <mat-label>{{ 'common.nameEn' | t }}</mat-label>
        <input matInput formControlName="nameEn" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'common.nameAr' | t }}</mat-label>
        <input matInput formControlName="nameAr" />
      </mat-form-field>
      <mat-form-field appearance="outline" class="wide">
        <mat-label>{{ 'common.description' | t }} (EN)</mat-label>
        <textarea matInput rows="2" formControlName="descEn"></textarea>
      </mat-form-field>
      <mat-form-field appearance="outline" class="wide">
        <mat-label>{{ 'common.description' | t }} (AR)</mat-label>
        <textarea matInput rows="2" formControlName="descAr"></textarea>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'common.price' | t }}</mat-label>
        <input matInput type="number" formControlName="price" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'products.salePrice' | t }}</mat-label>
        <input matInput type="number" formControlName="salePrice" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'common.stock' | t }}</mat-label>
        <input matInput type="number" formControlName="stock" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'common.category' | t }}</mat-label>
        <mat-select formControlName="categoryId">
          @for (c of data.categories; track entityId(c)) {
            <mat-option [value]="entityId(c)">{{ locName(c) }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
      <div class="wide">
        <div class="lbl">{{ 'common.images' | t }}</div>
        <app-image-uploader [images]="pics()" (imagesChange)="pics.set($event)" />
      </div>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'products.gender' | t }}</mat-label>
        <mat-select formControlName="gender">
          <mat-option value="">—</mat-option>
          <mat-option value="unisex">Unisex</mat-option>
          <mat-option value="male">Male</mat-option>
          <mat-option value="female">Female</mat-option>
        </mat-select>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'common.status' | t }}</mat-label>
        <mat-select formControlName="status">
          <mat-option value="published">{{ 'products.published' | t }}</mat-option>
          <mat-option value="unpublished">{{ 'products.unpublished' | t }}</mat-option>
          <mat-option value="archived">{{ 'products.archived' | t }}</mat-option>
        </mat-select>
      </mat-form-field>
      <div class="flags">
        <mat-checkbox formControlName="featured">{{ 'products.featured' | t }}</mat-checkbox>
        <mat-checkbox formControlName="newArrival">{{ 'products.newArrival' | t }}</mat-checkbox>
        <mat-checkbox formControlName="bestSeller">{{ 'products.bestSeller' | t }}</mat-checkbox>
      </div>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>{{ 'common.cancel' | t }}</button>
      <button mat-flat-button (click)="save()">{{ 'common.save' | t }}</button>
    </mat-dialog-actions>
  `,
  styles: `
    .dlg { display: grid; grid-template-columns: 1fr 1fr; gap: 10px 14px; min-width: min(680px, 92vw); padding-top: 8px; }
    .wide { grid-column: 1 / -1; }
    .lbl { font-size: 12px; font-weight: 700; color: #5c678c; margin-bottom: 8px; }
    .flags { grid-column: 1 / -1; display: flex; flex-wrap: wrap; gap: 8px; padding: 4px 0 8px; }
    @media (max-width: 640px) { .dlg { grid-template-columns: 1fr; } }
  `,
})
export class ProductDialog {
  readonly data = inject<{ product?: Product; categories: Category[] }>(MAT_DIALOG_DATA);
  private readonly ref = inject(MatDialogRef<ProductDialog, unknown>);
  private readonly fb = inject(FormBuilder);
  private readonly i18n = inject(I18nService);
  readonly entityId = entityId;
  readonly pics = signal<string[]>(this.data.product?.images ?? []);

  readonly form = this.fb.nonNullable.group({
    nameEn: [loc(localizedOf(this.data.product ?? {}), 'en'), Validators.required],
    nameAr: [loc(localizedOf(this.data.product ?? {}), 'ar'), Validators.required],
    descEn: [loc(this.data.product?.description ?? this.data.product?.descriptions, 'en')],
    descAr: [loc(this.data.product?.description ?? this.data.product?.descriptions, 'ar')],
    price: [this.data.product?.price ?? 0, Validators.required],
    salePrice: [this.data.product?.salePrice ?? 0],
    stock: [this.data.product?.stock ?? 0],
    categoryId: [this.categoryValue()],
    gender: [this.data.product?.gender ?? ''],
    status: [this.data.product?.status ?? 'published'],
    featured: [!!this.data.product?.flags?.featured],
    newArrival: [!!this.data.product?.flags?.newArrival],
    bestSeller: [!!this.data.product?.flags?.bestSeller],
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
    const description = { en: v.descEn, ar: v.descAr };
    this.ref.close({
      name,
      names: name,
      description,
      descriptions: description,
      price: Number(v.price),
      salePrice: v.salePrice ? Number(v.salePrice) : undefined,
      stock: Number(v.stock),
      categoryId: v.categoryId || undefined,
      images: this.pics(),
      gender: v.gender || undefined,
      status: v.status,
      flags: { featured: v.featured, newArrival: v.newArrival, bestSeller: v.bestSeller },
    });
  }

  private categoryValue(): string {
    const cat = this.data.product?.categoryId;
    return typeof cat === 'string' ? cat : entityId(cat);
  }
}

@Component({
  selector: 'app-products-page',
  imports: [
    MatTableModule,
    MatPaginatorModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    TranslatePipe,
    LocPipe,
    AsyncState,
  ],
  templateUrl: './products-page.html',
  styleUrl: './products-page.scss',
})
export class ProductsPage implements OnInit {
  private readonly api = inject(ProductsApi);
  private readonly categoriesApi = inject(CategoriesApi);
  private readonly dialog = inject(MatDialog);
  private readonly ui = inject(UiService);
  private readonly route = inject(ActivatedRoute);
  readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly rows = signal<Product[]>([]);
  readonly meta = signal<PageMeta>({ page: 1, limit: 20, total: 0, totalPages: 0 });
  readonly search = signal('');
  readonly status = signal('');
  readonly categories = signal<Category[]>([]);
  readonly displayedColumns = ['image', 'name', 'price', 'rating', 'stock', 'status', 'flags', 'actions'];
  readonly entityId = entityId;
  readonly localizedOf = localizedOf;
  private searchTimer?: ReturnType<typeof setTimeout>;
  private openedId = '';

  ngOnInit(): void {
    this.categoriesApi.list({ limit: 200 }).subscribe({
      next: (res) => this.categories.set(asList(res.data)),
    });
    this.load();
    this.route.queryParamMap.subscribe((q) => {
      const id = q.get('open') || '';
      if (id && id !== this.openedId) {
        this.openedId = id;
        this.openById(id);
      }
    });
  }

  load(page = this.meta().page, limit = this.meta().limit): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list({ page, limit, search: this.search() || undefined, status: this.status() || undefined }).subscribe({
      next: (res) => {
        this.rows.set(asList(res.data));
        if (res.meta) {
          this.meta.set(res.meta);
        } else {
          this.meta.set({ page, limit, total: asList(res.data).length, totalPages: 1 });
        }
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  onSearch(value: string): void {
    this.search.set(value);
    clearTimeout(this.searchTimer);
    this.searchTimer = setTimeout(() => this.load(1), 400);
  }

  filterStatus(status: string): void {
    this.status.set(status);
    this.load(1);
  }

  openById(id: string): void {
    this.api.get(id).subscribe({
      next: (res) => {
        if (res.data) this.open(res.data);
      },
    });
  }

  page(ev: PageEvent): void {
    this.load(ev.pageIndex + 1, ev.pageSize);
  }

  open(product?: Product): void {
    const ref = this.dialog.open(ProductDialog, {
      data: { product, categories: this.categories() },
      width: '760px',
      maxWidth: '94vw',
    });
    ref.afterClosed().subscribe((body: unknown) => {
      if (!body) {
        return;
      }
      const req = product
        ? this.api.update(entityId(product), body)
        : this.api.create(body);
      req.subscribe({
        next: () => {
          this.ui.success(this.i18n.t('common.save'));
          this.load();
        },
        error: (err: unknown) => this.ui.error(errMessage(err)),
      });
    });
  }

  remove(product: Product): void {
    this.api.remove(entityId(product)).subscribe({
      next: () => {
        this.ui.success(this.i18n.t('common.delete'));
        this.load();
      },
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }
}
