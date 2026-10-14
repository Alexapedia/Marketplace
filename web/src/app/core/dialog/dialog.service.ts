import { Injectable, signal } from '@angular/core';

export interface DialogRequest {
  title: string;
  message?: string;
  confirmKey?: string;
  danger?: boolean;
  /** When set, the dialog shows a text field and resolves with its value. */
  inputLabel?: string;
  inputRequired?: boolean;
}

interface OpenDialog extends DialogRequest {
  resolve: (value: string | null) => void;
}

/** In-app replacement for window.confirm / window.prompt. */
@Injectable({ providedIn: 'root' })
export class DialogService {
  readonly current = signal<OpenDialog | null>(null);

  confirm(req: Omit<DialogRequest, 'inputLabel' | 'inputRequired'>): Promise<boolean> {
    return this.open(req).then((v) => v !== null);
  }

  prompt(req: DialogRequest & { inputLabel: string }): Promise<string | null> {
    return this.open(req);
  }

  close(value: string | null): void {
    const dlg = this.current();
    this.current.set(null);
    dlg?.resolve(value);
  }

  private open(req: DialogRequest): Promise<string | null> {
    this.current()?.resolve(null);
    return new Promise((resolve) => this.current.set({ ...req, resolve }));
  }
}
