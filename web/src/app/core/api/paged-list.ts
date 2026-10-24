import { signal } from '@angular/core';
import { ApiClient, QueryParams } from './api-client';
import { asItems, PageMeta } from '../models/models';

/** Signal-backed "load more" list for paginated endpoints (`{ data, meta }`). */
export class PagedList<T> {
  readonly items = signal<T[]>([]);
  readonly meta = signal<PageMeta | null>(null);
  readonly loading = signal(true);
  readonly loadingMore = signal(false);
  readonly error = signal<string | null>(null);

  constructor(
    private readonly api: ApiClient,
    private readonly path: string,
    private readonly params: () => QueryParams = () => ({}),
    private readonly pageSize = 20,
  ) {}

  hasMore(): boolean {
    const m = this.meta();
    return !!m && m.page < m.totalPages;
  }

  reload(): void {
    this.fetch(1);
  }

  more(): void {
    const m = this.meta();
    if (m && !this.loadingMore() && this.hasMore()) this.fetch(m.page + 1);
  }

  /** Local edit after a mutation, without refetching. */
  update(fn: (items: T[]) => T[]): void {
    this.items.set(fn(this.items()));
  }

  private fetch(page: number): void {
    if (page === 1) {
      this.loading.set(true);
      this.error.set(null);
    } else {
      this.loadingMore.set(true);
    }
    this.api.get<T[]>(this.path, { ...this.params(), page, limit: this.pageSize }).subscribe({
      next: (res) => {
        const rows = asItems<T>(res.data);
        this.items.set(page === 1 ? rows : [...this.items(), ...rows]);
        this.meta.set(res.meta ?? null);
        this.loading.set(false);
        this.loadingMore.set(false);
      },
      error: (e: Error) => {
        if (page === 1) this.error.set(e.message);
        this.loading.set(false);
        this.loadingMore.set(false);
      },
    });
  }
}
