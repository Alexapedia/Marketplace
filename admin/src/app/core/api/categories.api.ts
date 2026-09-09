import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { Category } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class CategoriesApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<Category[]>> {
    return this.api.get<Category[]>('/admin/categories', params);
  }

  get(id: string): Observable<ApiResult<Category>> {
    return this.api.get<Category>(`/admin/categories/${id}`);
  }

  create(body: unknown): Observable<ApiResult<Category>> {
    return this.api.post<Category>('/admin/categories', body);
  }

  update(id: string, body: unknown): Observable<ApiResult<Category>> {
    return this.api.patch<Category>(`/admin/categories/${id}`, body);
  }

  remove(id: string): Observable<ApiResult<unknown>> {
    return this.api.delete<unknown>(`/admin/categories/${id}`);
  }
}
