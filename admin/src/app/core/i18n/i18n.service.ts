import { Directionality } from '@angular/cdk/bidi';
import { Injectable, computed, inject, signal } from '@angular/core';
import { Dict, Lang, ar, en } from './dicts';

const LANG_KEY = 'pm_lang';

@Injectable({ providedIn: 'root' })
export class I18nService {
  readonly lang = signal<Lang>(this.readLang());
  readonly dir = computed(() => (this.lang() === 'ar' ? 'rtl' : 'ltr'));
  private readonly bidi = inject(Directionality);

  constructor() {
    this.apply();
  }

  t(key: string): string {
    const value = this.lookup(this.lang() === 'ar' ? ar : en, key);
    return value ?? key;
  }

  setLang(lang: Lang): void {
    this.lang.set(lang);
    localStorage.setItem(LANG_KEY, lang);
    this.apply();
  }

  toggle(): void {
    this.setLang(this.lang() === 'en' ? 'ar' : 'en');
  }

  private lookup(dict: Dict, key: string): string | undefined {
    const parts = key.split('.');
    let current: string | Dict | undefined = dict;
    for (const part of parts) {
      if (!current || typeof current === 'string') {
        return undefined;
      }
      current = current[part];
    }
    return typeof current === 'string' ? current : undefined;
  }

  private readLang(): Lang {
    const saved = localStorage.getItem(LANG_KEY);
    return saved === 'ar' ? 'ar' : 'en';
  }

  private apply(): void {
    const dir = this.dir();
    document.documentElement.lang = this.lang();
    document.documentElement.dir = dir;
    // Material (sidenav margins, menus, dialogs) reads the app Directionality,
    // which only looks at <html dir> once at startup; tell it about the switch.
    if (this.bidi.value !== dir) {
      this.bidi.valueSignal.set(dir);
      this.bidi.change.emit(dir);
    }
  }
}
