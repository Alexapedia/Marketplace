import { registerLocaleData } from '@angular/common';
import localeAr from '@angular/common/locales/ar';
import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { App } from './app/app';

// Templates format dates with the active language ('ar' | 'en'); Angular only
// ships 'en' data by default, so Arabic dates threw NG0701 and blanked pages.
registerLocaleData(localeAr);

bootstrapApplication(App, appConfig).catch((err) => console.error(err));
