import { Component, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { PlatformApi } from '../../core/api/platform.api';
import { PlatformIssue } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-issues-page',
  imports: [TranslatePipe, DatePipe],
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
        this.reload();
      },
      error: (err: Error) => {
        this.busy.set(null);
        this.error.set(err.message);
      },
    });
  }

  private reload(): void {
    this.error.set(null);
    this.api
      .issues({
        status: this.status() || undefined,
        channel: this.channel() || undefined,
      })
      .subscribe({
        next: (res) => this.rows.set(res.data || []),
        error: (err: Error) => this.error.set(err.message),
      });
  }
}
