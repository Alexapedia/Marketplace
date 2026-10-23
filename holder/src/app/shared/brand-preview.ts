import { Component, computed, input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { onColor } from './maison';

/**
 * Live mini storefront header on a light and a dark surface, painted with a
 * tenant's colours and logo. Neutrals are the fixed Maison stone values for
 * each surface (independent of the holder's own theme), brand fills use
 * computed on-colours so any choice stays readable.
 */
@Component({
  selector: 'hd-brand-preview',
  imports: [MatIconModule, TranslatePipe],
  template: `
    @for (mode of modes; track mode) {
      <figure
        class="store"
        [class]="'store ' + mode"
        [style.--bp]="primary()"
        [style.--ba]="accent()"
        [style.--bop]="onPrimary()"
        [style.--boa]="onAccent()"
      >
        <figcaption class="cap">
          <mat-icon aria-hidden="true">{{ mode === 'light' ? 'light_mode' : 'dark_mode' }}</mat-icon>
          {{ (mode === 'light' ? 'tenants.previewLight' : 'tenants.previewDark') | t }}
        </figcaption>
        <div class="frame">
        <div class="header">
          <span class="logo">
            @if (logoFor(mode); as src) {
              <img [src]="src" [alt]="name()" />
            } @else {
              <span class="word">{{ name() || '—' }}</span>
            }
          </span>
          <span class="links" aria-hidden="true">
            <span class="on">{{ 'tenants.previewShop' | t }}</span>
            <span>{{ 'tenants.previewNew' | t }}</span>
            <span>{{ 'tenants.previewStores' | t }}</span>
          </span>
          <span class="icons" aria-hidden="true">
            <span class="search"><mat-icon>search</mat-icon></span>
            <span class="cart"><mat-icon>shopping_bag</mat-icon><i>2</i></span>
          </span>
        </div>
        <div class="hero">
          <span class="rule"></span>
          <span class="eyebrow">{{ name() || '—' }}</span>
          <span class="title">{{ 'tenants.previewHero' | t }}</span>
          <span class="cta">{{ 'tenants.previewCta' | t }}</span>
        </div>
        </div>
      </figure>
    }
  `,
  styles: `
    :host {
      display: grid;
      gap: 14px;
    }
    .store {
      --c-canvas: #f7f4ee;
      --c-surface: #ffffff;
      --c-line: #e5ded2;
      --c-ink: #16130f;
      --c-muted: #5e574d;
      --c-accent-ink: color-mix(in oklab, var(--ba) 62%, black);
      margin: 0;
      display: grid;
      gap: 6px;
    }
    .frame {
      position: relative;
      border-radius: var(--m-r-md);
      overflow: hidden;
      background: var(--c-canvas);
      border: 1px solid var(--m-line);
      box-shadow: var(--m-shadow-1);
      color: var(--c-ink);
      font-size: 12px;
    }
    .store.dark {
      --c-canvas: #0c0b09;
      --c-surface: #15130f;
      --c-line: #2c2821;
      --c-ink: #f5f0e6;
      --c-muted: #a79f92;
      --c-accent-ink: var(--ba);
    }
    .cap {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      color: var(--m-ink-muted);
      font-size: 10px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.12em;
    }
    :host-context([dir='rtl']) .cap {
      letter-spacing: 0;
    }
    .cap mat-icon {
      font-size: 13px;
      width: 13px;
      height: 13px;
    }
    .header {
      display: flex;
      align-items: center;
      gap: 14px;
      height: 54px;
      padding: 0 16px;
      background: color-mix(in srgb, var(--c-surface) 72%, transparent);
      border-bottom: 1px solid var(--c-line);
    }
    .logo {
      display: flex;
      align-items: center;
      height: 30px;
      min-width: 0;
      max-width: 120px;
      flex: none;
    }
    .logo img {
      max-height: 30px;
      max-width: 120px;
      object-fit: contain;
    }
    .word {
      font-family: var(--m-font-display);
      font-size: 16px;
      font-weight: 600;
      color: var(--c-ink);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .links {
      display: flex;
      gap: 12px;
      flex: 1;
      min-width: 0;
      overflow: hidden;
      color: var(--c-muted);
      white-space: nowrap;
    }
    .links .on {
      color: var(--c-ink);
      font-weight: 600;
      box-shadow: inset 0 -2px 0 var(--ba);
    }
    .icons {
      display: flex;
      gap: 6px;
      color: var(--c-ink);
    }
    .icons > span {
      position: relative;
      display: grid;
      place-items: center;
      width: 28px;
      height: 28px;
      border-radius: 50%;
      border: 1px solid var(--c-line);
    }
    .icons mat-icon {
      font-size: 16px;
      width: 16px;
      height: 16px;
    }
    .cart i {
      position: absolute;
      inset-block-start: -4px;
      inset-inline-end: -4px;
      display: grid;
      place-items: center;
      min-width: 15px;
      height: 15px;
      border-radius: var(--m-r-pill);
      background: var(--ba);
      color: var(--boa);
      font-size: 9px;
      font-style: normal;
      font-weight: 700;
    }
    .hero {
      position: relative;
      display: grid;
      justify-items: start;
      gap: 4px;
      margin: 12px;
      padding: 16px 18px 18px;
      border-radius: var(--m-r-sm);
      background:
        radial-gradient(120% 140% at 100% 0%, color-mix(in srgb, var(--ba) 22%, transparent), transparent 60%),
        var(--bp);
      color: var(--bop);
      overflow: hidden;
    }
    .rule {
      position: absolute;
      inset-inline: 0;
      top: 0;
      height: 1px;
      background: linear-gradient(90deg, var(--ba), transparent);
    }
    :host-context([dir='rtl']) .rule {
      background: linear-gradient(270deg, var(--ba), transparent);
    }
    .eyebrow {
      font-size: 10px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.16em;
      opacity: 0.8;
    }
    :host-context([dir='rtl']) .eyebrow {
      letter-spacing: 0;
    }
    .title {
      font-family: var(--m-font-display);
      font-size: 20px;
      font-weight: 600;
      line-height: 1.2;
    }
    .cta {
      margin-top: 8px;
      display: inline-flex;
      align-items: center;
      height: 28px;
      padding: 0 14px;
      border-radius: var(--m-r-pill);
      background: var(--ba);
      color: var(--boa);
      font-weight: 600;
    }
    .frame,
    .hero,
    .cta,
    .cart i {
      transition:
        background-color var(--m-dur-base) var(--m-ease-out),
        color var(--m-dur-base) var(--m-ease-out);
    }
    @media (max-width: 479.98px) {
      .links {
        display: none;
      }
      .header {
        justify-content: space-between;
      }
    }
  `,
})
export class HdBrandPreview {
  readonly name = input('');
  readonly primary = input('#071345');
  readonly accent = input('#c9a45c');
  readonly logo = input('');
  readonly logoDark = input('');
  readonly modes = ['light', 'dark'] as const;

  readonly onPrimary = computed(() => onColor(this.primary()));
  readonly onAccent = computed(() => onColor(this.accent()));

  /** Dark surfaces use the dark logo when present, else the regular one. */
  logoFor(mode: 'light' | 'dark'): string {
    return mode === 'dark' ? this.logoDark() || this.logo() : this.logo();
  }
}
