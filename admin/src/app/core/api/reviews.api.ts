import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { Review } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class ReviewsApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<Review[]>> {
    return this.api.get<Review[]>('/admin/reviews', params);
  }

  patch(id: string, body: { hidden?: boolean }): Observable<ApiResult<Review>> {
    return this.api.patch<Review>(`/admin/reviews/${id}`, body);
  }

  remove(id: string): Observable<ApiResult<unknown>> {
    return this.api.delete<unknown>(`/admin/reviews/${id}`);
  }
}
