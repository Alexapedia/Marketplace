// Tenant brand colours -> CSS custom properties consumed by styles/_maison.scss.
// Text colour on a brand fill is computed, never assumed, so any colour a
// store picks stays readable.

const INK = '#16130f';
const WHITE = '#ffffff';

function channel(v: number): number {
  const c = v / 255;
  return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}

export function luminance(hex: string): number | null {
  const m = /^#?([0-9a-f]{3}|[0-9a-f]{6})$/i.exec(hex.trim());
  if (!m) return null;
  let h = m[1];
  if (h.length === 3) h = h.split('').map((c) => c + c).join('');
  const n = parseInt(h, 16);
  return 0.2126 * channel((n >> 16) & 255) + 0.7152 * channel((n >> 8) & 255) + 0.0722 * channel(n & 255);
}

function contrast(a: number, b: number): number {
  const [hi, lo] = a > b ? [a, b] : [b, a];
  return (hi + 0.05) / (lo + 0.05);
}

/** The text colour (ink or white) with the higher contrast on [hex]. */
export function onColor(hex: string): string {
  const l = luminance(hex);
  if (l === null) return WHITE;
  return contrast(l, luminance(INK)!) >= contrast(l, 1) ? INK : WHITE;
}

export function applyBrand(primary: string, accent: string, root: HTMLElement = document.documentElement): void {
  root.style.setProperty('--brand-primary', primary);
  root.style.setProperty('--brand-accent', accent);
  root.style.setProperty('--brand-on-primary', onColor(primary));
  root.style.setProperty('--brand-on-accent', onColor(accent));
}
