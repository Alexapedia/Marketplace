import { Injectable, signal } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class ToastService {
  readonly message = signal('');

  show(msg: string, ms = 1800): void {
    this.message.set(msg);
    window.setTimeout(() => this.message.set(''), ms);
  }
}
