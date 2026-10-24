import { Component, DestroyRef, ElementRef, inject, input, output, signal, viewChild } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { Subscription } from 'rxjs';
import { PlatformApi } from '../core/api/platform.api';
import { TranslatePipe } from '../core/i18n/translate.pipe';

/** Mirrors backend ALLOWED_UPLOAD_MIMES (images only) and MAX_UPLOAD_BYTES. */
export const LOGO_TYPES = ['image/png', 'image/jpeg', 'image/webp'];
export const LOGO_MAX_BYTES = 8 * 1024 * 1024;

/**
 * Drag-and-drop / click-to-pick logo slot. Uploads to the platform upload
 * endpoint and emits the stored URL; `''` when removed.
 */
@Component({
  selector: 'hd-logo-drop',
  imports: [MatButtonModule, MatIconModule, TranslatePipe],
  template: `
    <div class="slot">
      <span class="label">{{ label() | t }}</span>
      <div
        class="zone"
        [class.dark]="surface() === 'dark'"
        [class.over]="over()"
        [class.filled]="!!value()"
        [class.busy]="progress() !== null"
        role="button"
        tabindex="0"
        [attr.aria-label]="(value() ? 'tenants.logoReplace' : 'tenants.logoDrop') | t"
        [attr.aria-describedby]="hintId"
        (click)="pick()"
        (keydown.enter)="pick()"
        (keydown.space)="$event.preventDefault(); pick()"
        (dragenter)="onDrag($event, true)"
        (dragover)="onDrag($event, true)"
        (dragleave)="onDrag($event, false)"
        (drop)="onDrop($event)"
      >
        @if (value() && progress() === null) {
          <img class="thumb m-enter" [src]="value()" alt="" />
          <span class="replace"><mat-icon aria-hidden="true">upload</mat-icon>{{ 'tenants.logoReplace' | t }}</span>
        } @else if (progress() !== null) {
          <span class="up">
            <span class="ring" [style.--p]="progress()! * 100">
              <span class="m-num">{{ pct() }}%</span>
            </span>
            <span>{{ 'tenants.logoUploading' | t }}</span>
          </span>
        } @else {
          <span class="empty">
            <span class="ic"><mat-icon aria-hidden="true">add_photo_alternate</mat-icon></span>
            <strong>{{ 'tenants.logoDrop' | t }}</strong>
          </span>
        }
        <span class="bar" [style.transform]="'scaleX(' + (progress() ?? 0) + ')'" aria-hidden="true"></span>
      </div>
      <div class="foot">
        <small [id]="hintId" [class.err]="!!error()" [attr.role]="error() ? 'alert' : null">{{
          (error() || 'tenants.logoHint') | t
        }}</small>
        @if (value() && progress() === null) {
          <button mat-button type="button" class="remove" (click)="remove()">
            <mat-icon>delete_outline</mat-icon>{{ 'tenants.logoRemove' | t }}
          </button>
        }
      </div>
      <input
        #file
        type="file"
        hidden
        [accept]="types.join(',')"
        (change)="onPicked($event)"
      />
    </div>
  `,
  styles: `
    .slot {
      display: grid;
      gap: 8px;
    }
    .label {
      font-size: 13px;
      font-weight: 600;
      color: var(--m-ink);
    }
    /* Each slot previews the logo on the surface it is made for, in either theme. */
    .zone {
      --zone-bg: #f1ece3;
      position: relative;
      display: grid;
      place-items: center;
      min-height: 132px;
      padding: 16px;
      box-sizing: border-box;
      border: 1.5px dashed rgb(22 19 15 / 0.22);
      border-radius: var(--m-r-md);
      background: var(--zone-bg);
      color: #5e574d;
      cursor: pointer;
      overflow: hidden;
      text-align: center;
      transition:
        border-color var(--m-dur-fast) var(--m-ease-out),
        background-color var(--m-dur-fast) var(--m-ease-out),
        transform var(--m-dur-base) var(--m-ease-out);
    }
    .zone.dark {
      --zone-bg: #15130f;
      color: #a79f92;
      border-color: rgb(245 240 230 / 0.22);
    }
    .zone:hover,
    .zone:focus-visible {
      border-color: var(--m-accent);
    }
    .zone.over {
      border-style: solid;
      border-color: var(--m-accent);
      background: color-mix(in srgb, var(--m-accent) 14%, var(--zone-bg));
      transform: scale(1.015);
    }
    .zone.filled {
      border-style: solid;
      border-color: #e5ded2;
    }
    .zone.dark.filled {
      border-color: #2c2821;
    }
    .zone.busy {
      cursor: progress;
    }
    .empty,
    .up {
      display: grid;
      justify-items: center;
      gap: 8px;
      font-size: 13px;
    }
    .empty strong {
      font-weight: 500;
      max-width: 26ch;
    }
    .ic {
      display: grid;
      place-items: center;
      width: 44px;
      height: 44px;
      border-radius: 50%;
      background: color-mix(in srgb, var(--m-accent) 18%, transparent);
      color: color-mix(in oklab, var(--m-accent) 62%, black);
    }
    .zone.dark .ic {
      color: var(--m-accent);
    }
    .thumb {
      max-width: 82%;
      max-height: 84px;
      object-fit: contain;
    }
    .replace {
      position: absolute;
      inset-block-end: 10px;
      inset-inline-end: 10px;
      display: inline-flex;
      align-items: center;
      gap: 4px;
      height: 28px;
      padding: 0 10px;
      border-radius: var(--m-r-pill);
      background: var(--m-glass);
      backdrop-filter: blur(18px) saturate(1.4);
      color: var(--m-ink);
      font-size: 12px;
      font-weight: 600;
      opacity: 0;
      transform: translate3d(0, 4px, 0);
      transition:
        opacity var(--m-dur-fast) var(--m-ease-out),
        transform var(--m-dur-fast) var(--m-ease-out);
    }
    .replace mat-icon {
      font-size: 16px;
      width: 16px;
      height: 16px;
    }
    .zone:hover .replace,
    .zone:focus-visible .replace {
      opacity: 1;
      transform: none;
    }
    @media (hover: none) {
      .replace {
        opacity: 1;
        transform: none;
      }
    }
    .ring {
      --p: 0;
      display: grid;
      place-items: center;
      width: 52px;
      height: 52px;
      border-radius: 50%;
      background:
        radial-gradient(closest-side, var(--zone-bg) 78%, transparent 80%),
        conic-gradient(var(--m-accent) calc(var(--p) * 1%), color-mix(in srgb, var(--m-accent) 18%, transparent) 0);
      font-size: 12px;
      font-weight: 600;
      color: inherit;
    }
    .bar {
      position: absolute;
      inset-inline: 0;
      bottom: 0;
      height: 3px;
      background: var(--m-accent);
      transform-origin: left center;
      transition: transform var(--m-dur-base) var(--m-ease-out);
    }
    :host-context([dir='rtl']) .bar {
      transform-origin: right center;
    }
    .foot {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
      min-height: 32px;
    }
    small {
      flex: 1;
      min-width: 0;
      color: var(--m-ink-muted);
      font-size: 12px;
    }
    small.err {
      color: var(--m-danger);
      font-weight: 600;
    }
    .remove {
      --mat-button-text-label-text-color: var(--m-danger);
      flex: none;
    }
  `,
})
export class HdLogoDrop {
  private readonly api = inject(PlatformApi);
  private static seq = 0;
  readonly label = input.required<string>();
  readonly value = input<string>('');
  readonly surface = input<'light' | 'dark'>('light');
  readonly valueChange = output<string>();

  readonly types = LOGO_TYPES;
  readonly hintId = `hd-logo-hint-${++HdLogoDrop.seq}`;
  readonly over = signal(false);
  readonly progress = signal<number | null>(null);
  readonly error = signal<string | null>(null);
  private readonly fileInput = viewChild.required<ElementRef<HTMLInputElement>>('file');
  private sub?: Subscription;

  constructor() {
    inject(DestroyRef).onDestroy(() => this.sub?.unsubscribe());
  }

  pct(): number {
    return Math.round((this.progress() ?? 0) * 100);
  }

  pick(): void {
    if (this.progress() !== null) return;
    this.fileInput().nativeElement.click();
  }

  onDrag(event: DragEvent, over: boolean): void {
    event.preventDefault();
    this.over.set(over);
  }

  onDrop(event: DragEvent): void {
    event.preventDefault();
    this.over.set(false);
    const file = event.dataTransfer?.files?.[0];
    if (file) this.upload(file);
  }

  onPicked(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    input.value = '';
    if (file) this.upload(file);
  }

  remove(): void {
    this.error.set(null);
    this.valueChange.emit('');
  }

  private upload(file: File): void {
    if (this.progress() !== null) return;
    if (!LOGO_TYPES.includes(file.type)) {
      this.error.set('tenants.logoType');
      return;
    }
    if (file.size > LOGO_MAX_BYTES) {
      this.error.set('tenants.logoSize');
      return;
    }
    this.error.set(null);
    this.progress.set(0);
    this.sub = this.api.uploadLogo(file).subscribe({
      next: (ev) => {
        this.progress.set(ev.progress);
        if (ev.result) {
          this.progress.set(null);
          this.valueChange.emit(ev.result.data.url);
        }
      },
      error: (err: Error) => {
        this.progress.set(null);
        this.error.set(err.message || 'tenants.logoFailed');
      },
    });
  }
}
