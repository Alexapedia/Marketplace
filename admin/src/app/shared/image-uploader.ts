import { Component, inject, input, output, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { ApiClient } from '../core/api/api-client';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { errMessage, UiService } from './ui.service';

@Component({
  selector: 'app-image-uploader',
  imports: [MatIconModule, MatButtonModule, TranslatePipe],
  template: `
    <div class="up">
      <div class="grid">
        @for (url of images(); track url; let i = $index) {
          <div class="tile m-enter">
            <img [src]="url" alt="" />
            @if (i === 0 && multiple()) {
              <span class="cover" aria-hidden="true">1</span>
            }
            <button class="x" type="button" mat-icon-button (click)="remove(i)" [attr.aria-label]="'common.delete' | t">
              <mat-icon>close</mat-icon>
            </button>
          </div>
        }
        @if (multiple() || images().length === 0) {
          <label class="add" [class.busy]="uploading()">
            <input type="file" accept="image/*" [multiple]="multiple()" (change)="pick($event)" />
            <span class="ic"><mat-icon>{{ uploading() ? 'hourglass_top' : 'add_photo_alternate' }}</mat-icon></span>
            <span>{{ (uploading() ? 'common.loading' : 'common.upload') | t }}</span>
          </label>
        }
      </div>
    </div>
  `,
  styles: `
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(112px, 1fr));
      gap: 12px;
    }
    .tile,
    .add {
      position: relative;
      aspect-ratio: 1;
      border-radius: var(--m-r-md);
      overflow: hidden;
      background: var(--m-surface-2);
    }
    .tile {
      border: 1px solid var(--m-line);
      box-shadow: var(--m-shadow-1);
    }
    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
      transition: transform var(--m-dur-lavish) var(--m-ease-out);
    }
    @media (hover: hover) and (pointer: fine) {
      .tile:hover img {
        transform: scale(1.06);
      }
    }
    .cover {
      position: absolute;
      top: 8px;
      inset-inline-start: 8px;
      min-width: 22px;
      height: 22px;
      padding: 0 6px;
      box-sizing: border-box;
      border-radius: var(--m-r-pill);
      display: grid;
      place-items: center;
      font-size: 11px;
      font-weight: 600;
      background: var(--m-accent);
      color: var(--m-on-accent);
    }
    .x {
      position: absolute;
      top: 4px;
      inset-inline-end: 4px;
      --mat-icon-button-state-layer-size: 32px;
      --mat-icon-button-icon-size: 18px;
      --mat-icon-button-icon-color: #ffffff;
      width: 32px;
      height: 32px;
      padding: 4px;
      background: color-mix(in srgb, #0c0b09 62%, transparent);
      backdrop-filter: blur(8px);
    }
    .x mat-icon {
      font-size: 18px;
      width: 18px;
      height: 18px;
    }
    .add {
      display: grid;
      place-content: center;
      justify-items: center;
      gap: 8px;
      border: 1px dashed color-mix(in srgb, var(--m-accent) 70%, var(--m-line));
      background: color-mix(in srgb, var(--m-accent) 6%, var(--m-surface));
      color: var(--m-accent-ink);
      cursor: pointer;
      font-size: 12px;
      font-weight: 600;
      text-align: center;
      padding: 8px;
      transition:
        background-color var(--m-dur-fast) var(--m-ease-out),
        border-color var(--m-dur-fast) var(--m-ease-out);
    }
    .add:hover {
      background: var(--m-accent-soft);
      border-color: var(--m-accent);
    }
    .add:focus-within {
      outline: 2px solid var(--m-accent);
      outline-offset: 2px;
    }
    .add.busy .ic {
      animation: m-bump var(--m-dur-lavish) var(--m-ease-in-out) infinite;
    }
    .ic {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      display: grid;
      place-items: center;
      background: var(--m-surface);
      box-shadow: var(--m-shadow-1);
    }
    .add input {
      position: absolute;
      width: 1px;
      height: 1px;
      opacity: 0;
      overflow: hidden;
    }
    @media (prefers-reduced-motion: reduce) {
      .add.busy .ic {
        animation: none;
      }
    }
  `,
})
export class ImageUploader {
  private readonly api = inject(ApiClient);
  private readonly ui = inject(UiService);

  readonly images = input<string[]>([]);
  readonly multiple = input(true);
  readonly imagesChange = output<string[]>();
  readonly uploading = signal(false);

  pick(event: Event): void {
    const input = event.target as HTMLInputElement;
    const files = Array.from(input.files ?? []);
    input.value = '';
    if (!files.length) {
      return;
    }
    this.uploading.set(true);
    const next = this.multiple() ? [...this.images()] : [];
    const run = (index: number) => {
      if (index >= files.length) {
        this.uploading.set(false);
        this.imagesChange.emit(next);
        return;
      }
      this.api.upload(files[index]).subscribe({
        next: (res) => {
          const url = res.data?.url;
          if (url) {
            next.push(url);
          }
          run(index + 1);
        },
        error: (err: unknown) => {
          this.uploading.set(false);
          this.ui.error(errMessage(err));
        },
      });
    };
    run(0);
  }

  remove(index: number): void {
    const next = this.images().filter((_, i) => i !== index);
    this.imagesChange.emit(next);
  }
}
