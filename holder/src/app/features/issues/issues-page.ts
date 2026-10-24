import { Component, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { PlatformApi } from '../../core/api/platform.api';
import { PageMeta, PlatformIssue } from '../../core/models/models';
import { HdState } from '../../shared/state';
import { MatButtonModule } from '@angular/material/button';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { MatIconModule } from '@angular/material/icon';
import { MAISON } from '../../shared/maison';

@Component({
  selector: 'app-issues-page',
  imports: [TranslatePipe, DatePipe, HdState, MatButtonModule, MatIconModule, MAISON],
  templateUrl: './issues-page.html',
  styleUrl: './issues-page.scss',
})
export class IssuesPage {
  private readonly api = inject(PlatformApi);
  readonly rows = signal<PlatformIssue[]>([]);
  readonly error = signal<string | null>(null);
  readonly status = signal<'open' | 'resolved' | ''>('open');
  readonly channel = signal('');
  readonly expanded = signal<string | null>(null);
  readonly busy = signal<string | null>(null);
  readonly loading = signal(true);
  readonly loadingMore = signal(false);
  readonly meta = signal<PageMeta | null>(null);

  readonly channels = ['', 'website', 'admin', 'mobile', 'holder', 'api'];

  constructor() {
    this.reload();
  }

  setStatus(value: 'open' | 'resolved' | ''): void {
    this.status.set(value);
    this.reload();
  }

  setChannel(value: string): void {
    this.channel.set(value);
    this.reload();
  }

  idOf(item: PlatformIssue): string {
    return item.id || item._id || '';
  }

  toggle(item: PlatformIssue): void {
    const id = this.idOf(item);
    this.expanded.set(this.expanded() === id ? null : id);
  }

  resolve(item: PlatformIssue, event: Event): void {
    event.stopPropagation();
    const id = this.idOf(item);
    if (!id || this.busy()) return;
    this.busy.set(id);
    this.api.resolveIssue(id).subscribe({
      next: () => {
        this.busy.set(null);
        if (this.status() === 'open') {
          this.rows.update((list) => list.filter((x) => this.idOf(x) !== id));
        } else {
          this.rows.update((list) =>
            list.map((x) => (this.idOf(x) === id ? { ...x, status: 'resolved' } : x)),
          );
        }
      },
      error: (err: Error) => {
        this.busy.set(null);
        this.error.set(err.message);
      },
    });
  }

  hasMore(): boolean {
    const m = this.meta();
    return !!m && m.page < m.totalPages;
  }

  reload(page = 1): void {
    if (page === 1) {
      this.loading.set(true);
      this.error.set(null);
    } else {
      this.loadingMore.set(true);
    }
    this.api
      .issues({
        status: this.status() || undefined,
        channel: this.channel() || undefined,
        page,
        limit: 20,
      })
      .subscribe({
        next: (res) => {
          const rows = res.data || [];
          this.rows.set(page === 1 ? rows : [...this.rows(), ...rows]);
          this.meta.set(res.meta ?? null);
          this.loading.set(false);
          this.loadingMore.set(false);
        },
        error: (err: Error) => {
          this.error.set(err.message);
          this.loading.set(false);
          this.loadingMore.set(false);
        },
      });
  }
}
