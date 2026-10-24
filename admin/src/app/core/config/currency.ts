export const CURRENCY_CODES = ['SAR', 'EGP', 'AED', 'USD', 'QAR', 'KWD', 'BHD', 'OMR'] as const;

const LABELS: Record<string, { en: string; ar: string }> = {
  SAR: { en: 'SAR', ar: 'ر.س' },
  EGP: { en: 'EGP', ar: 'ج.م' },
  AED: { en: 'AED', ar: 'د.إ' },
  USD: { en: 'USD', ar: 'USD' },
  QAR: { en: 'QAR', ar: 'ر.ق' },
  KWD: { en: 'KWD', ar: 'د.ك' },
  BHD: { en: 'BHD', ar: 'د.ب' },
  OMR: { en: 'OMR', ar: 'ر.ع' },
};

export function normalizeCurrency(code?: string | null): string {
  const value = String(code ?? 'SAR').trim().toUpperCase();
  return value || 'SAR';
}

export function currencyLabel(code: string | null | undefined, lang: 'en' | 'ar'): string {
  const normalized = normalizeCurrency(code);
  const row = LABELS[normalized];
  if (!row) return normalized;
  return lang === 'ar' ? row.ar : row.en;
}
