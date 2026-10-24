/** Lowercased `host[:port]` from a bare host or a full URL; '' when blank. */
export function normalizeHost(raw?: string): string {
  const value = (raw ?? '').trim();
  if (!value) return '';
  try {
    if (value.includes('://')) {
      return new URL(value).host.toLowerCase();
    }
  } catch {
    /* ignore */
  }
  return value.split('/')[0].toLowerCase();
}
