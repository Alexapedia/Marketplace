import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { CustomField } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class CustomFieldsApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<CustomField[]>> {
    return this.api.get<CustomField[]>('/admin/custom-fields', params);
  }

  create(body: unknown): Observable<ApiResult<CustomField>> {
    return this.api.post<CustomField>('/admin/custom-fields', body);
  }

  update(id: string, body: unknown): Observable<ApiResult<CustomField>> {
    return this.api.patch<CustomField>(`/admin/custom-fields/${id}`, body);
  }

  remove(id: string): Observable<ApiResult<unknown>> {
    return this.api.delete<unknown>(`/admin/custom-fields/${id}`);
  }
}
