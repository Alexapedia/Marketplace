import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { Order } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class OrdersApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<Order[]>> {
    return this.api.get<Order[]>('/admin/orders', params);
  }

  get(id: string): Observable<ApiResult<Order>> {
    return this.api.get<Order>(`/admin/orders/${id}`);
  }

  update(id: string, body: unknown): Observable<ApiResult<Order>> {
    return this.api.patch<Order>(`/admin/orders/${id}`, body);
  }

  updateStatus(id: string, status: string, rejectionReason?: string): Observable<ApiResult<Order>> {
    const body: { status: string; rejectionReason?: string } = { status };
    if (rejectionReason) {
      body.rejectionReason = rejectionReason;
    }
    return this.api.patch<Order>(`/admin/orders/${id}/status`, body);
  }
}
