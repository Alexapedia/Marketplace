import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { PageEvent } from '@angular/material/paginator';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { CustomersApi } from '../../core/api/customers.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { entityId, PageMeta, User } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-customer-profile-panel',
  imports: [DatePipe, MatDialogModule, MatButtonModule, TranslatePipe],
  template: `
    <h2 mat-dialog-title>{{ 'customers.profile' | t }}</h2>
    <mat-dialog-content class="profile">
      <div class="avatar">{{ initials() }}</div>
      <strong>{{ data.name }}</strong>
      <p>{{ data.email }}</p>
      <dl>
        <div><dt>{{ 'customers.phone' | t }}</dt><dd>{{ data.phone || '—' }}</dd></div>
        <div><dt>{{ 'common.status' | t }}</dt><dd>{{ data.status }}</dd></div>
        <div><dt>{{ 'customers.joined' | t }}</dt><dd>{{ data.createdAt | date: 'medium' }}</dd></div>
      </dl>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-flat-button mat-dialog-close>{{ 'common.close' | t }}</button>
    </mat-dialog-actions>
  `,
  styles: `
    .profile { display: grid; justify-items: start; gap: 4px; min-width: min(360px, 86vw); }
    .avatar { width: 52px; height: 52px; border-radius: 16px; display: grid; place-items: center; background: #071345; color: #fff; font-weight: 800; margin-bottom: 8px; }
    strong { font-size: 18px; }
    p { margin: 0 0 12px; color: #5c678c; }
    dl { width: 100%; margin: 0; display: grid; gap: 10px; }
    dt { font-size: 11px; font-weight: 700; color: #5c678c; text-transform: uppercase; letter-spacing: .04em; }
    dd { margin: 2px 0 0; font-weight: 600; }
  `,
})
export class CustomerProfilePanel {
  readonly data = inject<User>(MAT_DIALOG_DATA);
  initials(): string {
    return (this.data.name || this.data.email || 'C').slice(0, 1).toUpperCase();
  }
}

@Component({
  selector: 'app-customers-page',
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
    AsyncState,
  ],
  templateUrl: './customers-page.html',
  styleUrl: './customers-page.scss',
})
export class CustomersPage implements OnInit {
  private readonly api = inject(CustomersApi);
  private readonly dialog = inject(MatDialog);
  private readonly ui = inject(UiService);
  readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly rows = signal<User[]>([]);
  readonly meta = signal<PageMeta>({ page: 1, limit: 20, total: 0, totalPages: 0 });
  readonly search = signal('');
  readonly status = signal('');
  readonly cols = ['name', 'email', 'phone', 'status', 'actions'];
  readonly entityId = entityId;

  ngOnInit(): void {
    this.load();
  }

  load(page = this.meta().page, limit = this.meta().limit): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list({ page, limit, search: this.search() || undefined, status: this.status() || undefined }).subscribe({
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

  onSearch(value: string): void {
    this.search.set(value);
    this.load(1);
  }

  filterStatus(status: string): void {
    this.status.set(status);
    this.load(1);
  }

  page(ev: PageEvent): void {
    this.load(ev.pageIndex + 1, ev.pageSize);
  }

  profile(user: User): void {
    this.dialog.open(CustomerProfilePanel, { data: user, width: '420px' });
  }

  toggle(user: User): void {
    const next = user.status === 'blocked' ? 'active' : 'blocked';
    this.api.updateStatus(entityId(user), next).subscribe({
      next: () => {
        this.ui.success(this.i18n.t('common.save'));
        this.load();
      },
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }
}
