import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { ChatMessage, CustomOrder } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class CustomOrdersApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<CustomOrder[]>> {
    return this.api.get<CustomOrder[]>('/admin/custom-orders', params);
  }

  get(id: string): Observable<ApiResult<CustomOrder>> {
    return this.api.get<CustomOrder>(`/admin/custom-orders/${id}`);
  }

  update(id: string, body: unknown): Observable<ApiResult<CustomOrder>> {
    return this.api.patch<CustomOrder>(`/admin/custom-orders/${id}`, body);
  }

  sendProposal(id: string, body: unknown): Observable<ApiResult<CustomOrder>> {
    return this.api.post<CustomOrder>(`/admin/custom-orders/${id}/proposals`, body);
  }

  messages(id: string): Observable<ApiResult<ChatMessage[]>> {
    return this.api.get<ChatMessage[]>(`/admin/custom-orders/${id}/messages`);
  }
}
