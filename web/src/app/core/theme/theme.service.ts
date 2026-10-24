import { Injectable, signal } from '@angular/core';

const THEME_KEY = 'zz_theme';

export type ThemeMode = 'light' | 'dark';

@Injectable({ providedIn: 'root' })
export class ThemeService {
  readonly mode = signal<ThemeMode>(this.read());

  constructor() {
    this.apply(this.mode());
  }

  toggle(): void {
    this.set(this.mode() === 'light' ? 'dark' : 'light');
  }

  set(mode: ThemeMode): void {
    this.mode.set(mode);
    localStorage.setItem(THEME_KEY, mode);
    this.apply(mode);
  }

  private read(): ThemeMode {
    return localStorage.getItem(THEME_KEY) === 'dark' ? 'dark' : 'light';
  }

  private apply(mode: ThemeMode): void {
    document.documentElement.dataset['theme'] = mode;
    document.body.style.colorScheme = mode;
  }
}
