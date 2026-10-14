import { inject, Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';

@Injectable({ providedIn: 'root' })
export class UiService {
  private readonly snack = inject(MatSnackBar);

  success(message: string): void {
    this.snack.open(message, undefined, { duration: 2800, panelClass: 'snack-ok' });
  }

  error(message: string): void {
    this.snack.open(message, undefined, { duration: 4200, panelClass: 'snack-err' });
  }
}

export function errMessage(err: unknown, fallback = requestFailedText()): string {
  if (err instanceof Error && err.message) {
    return err.message;
  }
  return fallback;
}

export function asList<T>(data: T[] | { items?: T[] } | null | undefined): T[] {
  if (Array.isArray(data)) {
    return data;
  }
  if (data && typeof data === 'object' && Array.isArray(data.items)) {
    return data.items;
  }
  return [];
}

/** Fallback error text in the active UI language (set on <html lang>). */
export function requestFailedText(): string {
  return document.documentElement.lang === 'ar' ? 'تعذّر تنفيذ الطلب' : 'Request failed';
}
