import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { Product } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class ProductsApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<Product[]>> {
    return this.api.get<Product[]>('/admin/products', params);
  }

  get(id: string): Observable<ApiResult<Product>> {
    return this.api.get<Product>(`/admin/products/${id}`);
  }

  create(body: unknown): Observable<ApiResult<Product>> {
    return this.api.post<Product>('/admin/products', body);
  }

  update(id: string, body: unknown): Observable<ApiResult<Product>> {
    return this.api.patch<Product>(`/admin/products/${id}`, body);
  }

  remove(id: string): Observable<ApiResult<unknown>> {
    return this.api.delete<unknown>(`/admin/products/${id}`);
  }
}
