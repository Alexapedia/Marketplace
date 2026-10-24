import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { Banner } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class AdsApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<Banner[]>> {
    return this.api.get<Banner[]>('/admin/ads', params);
  }

  create(body: unknown): Observable<ApiResult<Banner>> {
    return this.api.post<Banner>('/admin/ads', body);
  }

  update(id: string, body: unknown): Observable<ApiResult<Banner>> {
    return this.api.patch<Banner>(`/admin/ads/${id}`, body);
  }

  remove(id: string): Observable<ApiResult<unknown>> {
    return this.api.delete<unknown>(`/admin/ads/${id}`);
  }
}
