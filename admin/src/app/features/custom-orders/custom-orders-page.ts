import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { PageEvent } from '@angular/material/paginator';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSelectModule } from '@angular/material/select';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatTableModule } from '@angular/material/table';
import { CustomOrdersApi } from '../../core/api/custom-orders.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { CustomOrder, entityId, PageMeta } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { ImageUploader } from '../../shared/image-uploader';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-custom-orders-page',
  imports: [
    DatePipe,
    ReactiveFormsModule,
    MatTableModule,
    MatPaginatorModule,
    MatButtonModule,
    MatIconModule,
    MatSidenavModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatCardModule,
    TranslatePipe,
    AsyncState,
    ImageUploader,
  ],
  templateUrl: './custom-orders-page.html',
  styleUrl: './custom-orders-page.scss',
})
export class CustomOrdersPage implements OnInit {
  private readonly api = inject(CustomOrdersApi);
  private readonly ui = inject(UiService);
  private readonly router = inject(Router);
  private readonly fb = inject(FormBuilder);
  readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly rows = signal<CustomOrder[]>([]);
  readonly meta = signal<PageMeta>({ page: 1, limit: 20, total: 0, totalPages: 0 });
  readonly selected = signal<CustomOrder | null>(null);
  readonly cols = ['id', 'status', 'createdAt', 'actions'];
  readonly entityId = entityId;
  readonly status = signal('');
  readonly statuses = [
    'submitted',
    'under_review',
    'quote_sent',
    'waiting_confirmation',
    'confirmed',
    'rejected',
    'completed',
  ];

  readonly pics = signal<string[]>([]);
  readonly proposal = this.fb.nonNullable.group({
    productName: ['', Validators.required],
    specifications: [''],
    price: [0, Validators.required],
    quantity: [1],
    estimatedDays: [7],
    notes: [''],
  });

  ngOnInit(): void {
    this.load();
  }

  load(page = this.meta().page, limit = this.meta().limit): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list({ page, limit, status: this.status() || undefined }).subscribe({
      next: (res) => {
        this.rows.set(asList(res.data));
        this.meta.set(res.meta ?? { page, limit, total: asList(res.data).length, totalPages: 1 });
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  page(ev: PageEvent): void {
    this.load(ev.pageIndex + 1, ev.pageSize);
  }

  open(row: CustomOrder): void {
    this.api.get(entityId(row)).subscribe({
      next: (res) => this.selected.set(res.data),
      error: () => this.selected.set(row),
    });
  }

  customer(row: CustomOrder): string {
    const u = row.userId;
    if (u && typeof u === 'object') {
      return u.name || u.email;
    }
    return String(u ?? '—');
  }

  sendProposal(): void {
    const order = this.selected();
    if (!order || this.proposal.invalid) {
      this.proposal.markAllAsTouched();
      return;
    }
    const v = this.proposal.getRawValue();
    const images = this.pics();
    let specifications: Record<string, unknown> | string = v.specifications;
    try {
      specifications = v.specifications.trim().startsWith('{')
        ? (JSON.parse(v.specifications) as Record<string, unknown>)
        : { notes: v.specifications };
    } catch {
      specifications = { notes: v.specifications };
    }
    this.api
      .sendProposal(entityId(order), {
        productName: v.productName,
        images,
        specifications,
        price: Number(v.price),
        quantity: Number(v.quantity),
        estimatedDays: Number(v.estimatedDays),
        notes: v.notes,
      })
      .subscribe({
        next: (res) => {
          this.ui.success(this.i18n.t('common.save'));
          this.selected.set(res.data);
          this.pics.set([]);
          this.proposal.reset({
            productName: '',
            specifications: '',
            price: 0,
            quantity: 1,
            estimatedDays: 7,
            notes: '',
          });
          this.load();
        },
        error: (err: unknown) => this.ui.error(errMessage(err)),
      });
  }

  openChat(row: CustomOrder): void {
    void this.router.navigate(['/chat'], { queryParams: { customOrderId: entityId(row) } });
  }
}
