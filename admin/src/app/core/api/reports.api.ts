import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { ReportsData } from '../models/models';
import { ApiClient, ApiResult } from './api-client';

@Injectable({ providedIn: 'root' })
export class ReportsApi {
  private readonly api = inject(ApiClient);

  get(from?: string, to?: string): Observable<ApiResult<ReportsData>> {
    return this.api.get<ReportsData>('/admin/reports', { from, to });
  }
}
