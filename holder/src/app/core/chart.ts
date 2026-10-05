export function areaPath(values: number[], w = 360, h = 96): { w: number; h: number; line: string; area: string } {
  if (!values.length) {
    return { w, h, line: '', area: '' };
  }
  const max = Math.max(...values, 1);
  const step = values.length > 1 ? w / (values.length - 1) : w;
  const pts = values.map((v, i) => {
    const x = i * step;
    const y = h - (v / max) * (h - 10) - 5;
    return [x, y] as const;
  });
  const line = pts.map((p, i) => `${i ? 'L' : 'M'}${p[0].toFixed(1)},${p[1].toFixed(1)}`).join(' ');
  const last = pts[pts.length - 1];
  const area = `${line} L${last[0].toFixed(1)},${h} L0,${h} Z`;
  return { w, h, line, area };
}

export function barPct(value: number, max: number): number {
  if (max <= 0) return 0;
  return Math.max(4, Math.round((value / max) * 100));
}
