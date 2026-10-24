import { Injectable, computed, signal } from '@angular/core';
import { ar, en, Lang } from './dicts';

const LANG_KEY = 'zz_lang';

@Injectable({ providedIn: 'root' })
export class I18nService {
  readonly lang = signal<Lang>(this.readLang());
  readonly dir = computed(() => (this.lang() === 'ar' ? 'rtl' : 'ltr'));

  constructor() {
    this.apply();
  }

  t(key: string): string {
    const dict = this.lang() === 'ar' ? ar : en;
    return dict[key] ?? key;
  }

  setLang(lang: Lang): void {
    this.lang.set(lang);
    localStorage.setItem(LANG_KEY, lang);
    this.apply();
  }

  toggle(): void {
    this.setLang(this.lang() === 'en' ? 'ar' : 'en');
  }

  private readLang(): Lang {
    const saved = localStorage.getItem(LANG_KEY);
    return saved === 'en' ? 'en' : 'ar';
  }

  private apply(): void {
    document.documentElement.lang = this.lang();
    document.documentElement.dir = this.dir();
  }
}
