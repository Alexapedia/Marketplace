import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { AppConfig } from '../models/models';
import { ApiClient, ApiResult } from './api-client';

@Injectable({ providedIn: 'root' })
export class AppConfigApi {
  private readonly api = inject(ApiClient);

  get(): Observable<ApiResult<AppConfig>> {
    return this.api.get<AppConfig>('/admin/app-config');
  }

  update(body: unknown): Observable<ApiResult<AppConfig>> {
    return this.api.patch<AppConfig>('/admin/app-config', body);
  }

  upload(file: File): Observable<ApiResult<{ url: string }>> {
    return this.api.upload<{ url: string }>(file);
  }
}
