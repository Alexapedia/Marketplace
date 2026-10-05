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
          <div class="tile">
            <img [src]="url" alt="" />
            <button class="x" type="button" mat-icon-button (click)="remove(i)">
              <mat-icon>close</mat-icon>
            </button>
          </div>
        }
        @if (multiple() || images().length === 0) {
          <label class="add">
            <input type="file" accept="image/*" [multiple]="multiple()" (change)="pick($event)" />
            <mat-icon>{{ uploading() ? 'hourglass_top' : 'add_photo_alternate' }}</mat-icon>
            <span>{{ (uploading() ? 'common.loading' : 'common.upload') | t }}</span>
          </label>
        }
      </div>
    </div>
  `,
  styles: `
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(108px, 1fr));
      gap: 10px;
    }
    .tile,
    .add {
      position: relative;
      aspect-ratio: 1;
      border-radius: 16px;
      overflow: hidden;
      background: #e8ebf6;
    }
    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }
    .x {
      position: absolute;
      top: 2px;
      inset-inline-end: 2px;
      background: rgba(7, 19, 69, 0.72);
      color: #fff;
      width: 30px;
      height: 30px;
    }
    .add {
      display: grid;
      place-items: center;
      gap: 4px;
      border: 1.5px dashed color-mix(in srgb, #071345 22%, transparent);
      color: #071345;
      cursor: pointer;
      font-size: 12px;
      font-weight: 700;
      text-align: center;
      padding: 8px;
    }
    .add input { display: none; }
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
