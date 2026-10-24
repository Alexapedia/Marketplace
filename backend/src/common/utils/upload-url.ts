/**
 * Public path of an uploaded file. It carries no host: web clients load it
 * through their own `/uploads` proxy on whatever domain serves the store, and
 * the mobile app resolves it against its API origin.
 */
export function uploadPath(filename: string): string {
  return `/uploads/${filename}`;
}

// Only our own upload names (UUID + extension), so an external URL that also
// happens to contain `/uploads/` is never rewritten.
const ABSOLUTE_UPLOAD =
  /^https?:\/\/[^/]+\/uploads\/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.[a-z0-9]+)$/i;

function isPlainObject(value: unknown): value is Record<string, unknown> {
  if (value === null || typeof value !== 'object') return false;
  const proto = Object.getPrototypeOf(value) as unknown;
  return proto === Object.prototype || proto === null;
}

/**
 * Rewrites stored absolute upload URLs (`http://host/uploads/<file>`) to
 * `/uploads/<file>`, deeply through plain objects and arrays. Unchanged
 * values keep their reference, so callers can detect what changed.
 */
export function relativizeUploads(value: unknown): unknown {
  if (typeof value === 'string') {
    const match = ABSOLUTE_UPLOAD.exec(value);
    return match ? uploadPath(match[1]) : value;
  }
  if (Array.isArray(value)) {
    const next = value.map((item) => relativizeUploads(item));
    return next.some((item, i) => item !== value[i]) ? next : value;
  }
  if (isPlainObject(value)) {
    let changed = false;
    const next: Record<string, unknown> = {};
    for (const [key, item] of Object.entries(value)) {
      next[key] = relativizeUploads(item);
      if (next[key] !== item) changed = true;
    }
    return changed ? next : value;
  }
  return value;
}
