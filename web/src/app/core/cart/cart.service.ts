import { inject, Injectable, signal } from '@angular/core';
import { catchError, map, of, tap } from 'rxjs';
import { ApiClient } from '../api/api-client';
import { TOKEN_KEY } from '../auth/token';
import { Cart, CartItem } from '../models/models';

@Injectable({ providedIn: 'root' })
export class CartService {
  private readonly api = inject(ApiClient);

  readonly items = signal<CartItem[]>([]);
  readonly count = signal(0);

  refresh(): void {
    if (!localStorage.getItem(TOKEN_KEY)) {
      this.clearLocal();
      return;
    }
    this.api
      .get<Cart>('/cart')
      .pipe(
        map((res) => res.data?.items ?? []),
        catchError(() => of([] as CartItem[])),
        tap((items) => this.setItems(items)),
      )
      .subscribe();
  }

  add(productId: string, quantity: number, size?: string) {
    return this.api.post<Cart>('/cart/items', { productId, quantity, size }).pipe(
      tap((res) => this.setItems(res.data?.items ?? [])),
    );
  }

  updateQty(itemId: string, quantity: number) {
    return this.api.patch<Cart>(`/cart/items/${itemId}`, { quantity }).pipe(
      tap((res) => this.setItems(res.data?.items ?? [])),
    );
  }

  remove(itemId: string) {
    return this.api.delete<Cart>(`/cart/items/${itemId}`).pipe(
      tap((res) => this.setItems(res.data?.items ?? [])),
    );
  }

  clearLocal(): void {
    this.items.set([]);
    this.count.set(0);
  }

  private setItems(items: CartItem[]): void {
    this.items.set(items);
    this.count.set(items.reduce((n, i) => n + i.quantity, 0));
  }
}
