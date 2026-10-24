import { ChangeDetectionStrategy, Component, input } from '@angular/core';

/** Hairline (1.6px stroke) icon set used across the storefront. Decorative: always aria-hidden. */
const PATHS: Record<string, string> = {
  bag: 'M5 8h14l-1.2 11.2a2 2 0 0 1-2 1.8H8.2a2 2 0 0 1-2-1.8L5 8Z|M9 8V6.5a3 3 0 0 1 6 0V8',
  bagPlus:
    'M5 8h14l-1.2 11.2a2 2 0 0 1-2 1.8H8.2a2 2 0 0 1-2-1.8L5 8Z|M9 8V6.5a3 3 0 0 1 6 0V8|M12 11.5v5|M9.5 14h5',
  bell: 'M6 16V11a6 6 0 1 1 12 0v5l1.5 2h-15L6 16Z|M10 20.5a2 2 0 0 0 4 0',
  user: 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z|M4.5 20.5c1.2-3.6 4-5.5 7.5-5.5s6.3 1.9 7.5 5.5',
  search: 'M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14Z|M20 20l-4-4',
  moon: 'M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5Z',
  sun: 'M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z|M12 2.5v2|M12 19.5v2|M4.6 4.6l1.4 1.4|M18 18l1.4 1.4|M2.5 12h2|M19.5 12h2|M4.6 19.4 6 18|M18 6l1.4-1.4',
  globe:
    'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z|M3 12h18|M12 3c2.5 2.6 3.5 5.6 3.5 9s-1 6.4-3.5 9c-2.5-2.6-3.5-5.6-3.5-9s1-6.4 3.5-9Z',
  logout: 'M15 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3|M10 16l-4-4 4-4|M6 12h10',
  home: 'M4 10.5 12 4l8 6.5V19a1.5 1.5 0 0 1-1.5 1.5H15v-6H9v6H5.5A1.5 1.5 0 0 1 4 19v-8.5Z',
  grid: 'M4 4h6.5v6.5H4z|M13.5 4H20v6.5h-6.5z|M4 13.5h6.5V20H4z|M13.5 13.5H20V20h-6.5z',
  box: 'M4 7.5 12 3.5l8 4v9l-8 4-8-4v-9Z|M4 7.5l8 4 8-4|M12 11.5v9',
  heart: 'M12 20s-7.5-4.6-7.5-10.2A4.3 4.3 0 0 1 12 7.3a4.3 4.3 0 0 1 7.5 2.5C19.5 15.4 12 20 12 20Z',
  truck:
    'M3 6.5h11v9H3z|M14 9.5h3.5L21 13v2.5h-7|M7 18.5a1.8 1.8 0 1 0 0-3.6 1.8 1.8 0 0 0 0 3.6Z|M17 18.5a1.8 1.8 0 1 0 0-3.6 1.8 1.8 0 0 0 0 3.6Z',
  cash: 'M3 7h18v10H3z|M12 14.5a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5Z|M6 10v.01|M18 14v.01',
  spark:
    'M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8L12 3Z|M18.5 16.5l.7 1.8 1.8.7-1.8.7-.7 1.8-.7-1.8-1.8-.7 1.8-.7.7-1.8Z',
  returns: 'M4 12a8 8 0 1 0 2.4-5.7|M4 4v4.5h4.5',
  arrow: 'M5 12h14|M13 6l6 6-6 6',
  back: 'M19 12H5|M11 6l-6 6 6 6',
  chevron: 'M9 6l6 6-6 6',
  close: 'M6 6l12 12|M18 6 6 18',
  plus: 'M12 5v14|M5 12h14',
  minus: 'M5 12h14',
  trash: 'M4.5 7h15|M9.5 7V5h5v2|M6.5 7l.8 12a1.5 1.5 0 0 0 1.5 1.4h6.4a1.5 1.5 0 0 0 1.5-1.4l.8-12',
  pin: 'M12 21s-6.5-5.6-6.5-11a6.5 6.5 0 0 1 13 0c0 5.4-6.5 11-6.5 11Z|M12 12a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z',
  edit: 'M4 20h4L19 9l-4-4L4 16v4Z|M13.5 6.5l4 4',
  filter: 'M4 6h16|M7 12h10|M10 18h4',
  phone:
    'M6.5 3.5h3l1.5 4-2 1.3a11 11 0 0 0 6.2 6.2l1.3-2 4 1.5v3a2 2 0 0 1-2 2A16.5 16.5 0 0 1 4.5 5.5a2 2 0 0 1 2-2Z',
  mail: 'M3.5 6h17v12h-17z|M3.5 7l8.5 6.5L20.5 7',
  check: 'M5 12.5l4.5 4.5L19 7.5',
  chat: 'M4 5.5h16v11H9l-5 4v-15Z',
  clip: 'M20 11.5l-8 8a5 5 0 0 1-7-7l8.5-8.5a3.3 3.3 0 0 1 4.7 4.7L9.8 17.2a1.7 1.7 0 0 1-2.4-2.4l7.4-7.3',
  shield: 'M12 3.5 19 6v6c0 4.4-3 7.6-7 8.5-4-.9-7-4.1-7-8.5V6l7-2.5Z|M9 12l2 2 4-4',
  send: 'M4 12 20 4l-6 16-3-7-7-1Z',
};

@Component({
  selector: 'm-icon',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'm-icon', 'aria-hidden': 'true' },
  template: `
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      [attr.stroke-width]="stroke()"
      stroke-linecap="round"
      stroke-linejoin="round"
      focusable="false"
    >
      @for (d of paths(); track $index) {
        <path [attr.d]="d" />
      }
    </svg>
  `,
})
export class Icon {
  readonly name = input.required<string>();
  readonly stroke = input(1.6);

  paths(): string[] {
    return (PATHS[this.name()] ?? '').split('|');
  }
}
