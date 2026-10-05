import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { I18nService } from './core/i18n/i18n.service';
import { ThemeService } from './core/theme/theme.service';
import { StoreConfigService } from './core/config/store-config.service';
import { TranslatePipe } from './core/i18n/translate.pipe';
import { TelemetryService } from './core/telemetry/telemetry.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, TranslatePipe],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  readonly store = inject(StoreConfigService);

  constructor() {
    inject(ThemeService);
    inject(I18nService);
    inject(TelemetryService).boot('admin');
  }
}
