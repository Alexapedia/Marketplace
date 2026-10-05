import { Component, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { I18nService } from '../../core/i18n/i18n.service';
import { LocPipe, TranslatePipe } from '../../core/i18n/translate.pipe';
import {
  Category,
  CustomField,
  CustomOrder,
  flattenCategories,
  loc,
  pid,
} from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { ToastService } from '../../core/toast/toast.service';

@Component({
  selector: 'app-custom-new-page',
  imports: [FormsModule, PageBar, TranslatePipe, LocPipe],
  templateUrl: './custom-new-page.html',
})
export class CustomNewPage implements OnInit {
  private readonly api = inject(ApiClient);
  private readonly router = inject(Router);
  readonly i18n = inject(I18nService);
  private readonly toast = inject(ToastService);

  categories = signal<Category[]>([]);
  fields = signal<CustomField[]>([]);
  categoryId = '';
  description = '';
  fieldValues: Record<string, unknown> = {};
  files: File[] = [];
  error = signal('');

  ngOnInit(): void {
    this.api.get<Category[]>('/categories').subscribe({
      next: (res) => this.categories.set(flattenCategories(res.data ?? [])),
    });
  }

  onCategoryChange(): void {
    if (!this.categoryId) {
      this.fields.set([]);
      return;
    }
    this.api.get<CustomField[]>('/custom-fields', { categoryId: this.categoryId }).subscribe({
      next: (res) => this.fields.set(res.data ?? []),
    });
  }

  onFiles(ev: Event): void {
    const input = ev.target as HTMLInputElement;
    this.files = input.files ? Array.from(input.files) : [];
  }

  fieldLabel(f: CustomField): string {
    return loc(f.labels, this.i18n.lang()) || 'Field';
  }

  submit(ev: Event): void {
    ev.preventDefault();
    this.error.set('');
    const form = new FormData();
    form.append('categoryId', this.categoryId);
    form.append('description', this.description);
    form.append('status', 'submitted');
    form.append('fields', JSON.stringify(this.fieldValues));
    for (const file of this.files) {
      form.append('attachments', file);
    }
    this.api.postForm<CustomOrder>('/custom-orders', form).subscribe({
      next: (res) => void this.router.navigate(['/custom', res.data._id]),
      error: (e) => this.error.set(e.message),
    });
  }

  cats(): Category[] {
    return this.categories();
  }

  trackCat(c: Category): string {
    return pid(c);
  }
}
