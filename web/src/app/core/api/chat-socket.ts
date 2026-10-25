import { Injectable, signal } from '@angular/core';
import { io, Socket } from 'socket.io-client';
import { Subject } from 'rxjs';
import { TOKEN_KEY } from '../auth/token';
import { TokenRefresher } from '../auth/token-refresher';
import { ChatMessage } from '../models/models';

/**
 * The customer's live chat for one custom order. Customers join and post by
 * `customOrderId`; the server only lets staff use a conversation id.
 */
@Injectable({ providedIn: 'root' })
export class ChatSocket {
  private socket?: Socket;
  private customOrderId = '';
  /** Token renewals in a row without a successful connect. */
  private renewals = 0;
  readonly connected = signal(false);
  readonly incoming = new Subject<ChatMessage>();

  constructor(private readonly refresher: TokenRefresher) {}

  /** Opens the socket if needed and joins this order's chat (again on every reconnect). */
  join(customOrderId: string): void {
    this.customOrderId = customOrderId;
    if (!localStorage.getItem(TOKEN_KEY) || !customOrderId) return;
    if (!this.socket) {
      this.open();
      return;
    }
    if (this.socket.connected) {
      this.emitJoin();
    } else {
      this.socket.connect();
    }
  }

  private open(): void {
    const socket = io('/chat', {
      path: '/socket.io',
      transports: ['websocket'],
      upgrade: false,
      // Evaluated on every (re)connect and read where the HTTP interceptor
      // stores a refreshed token, and kept out of the URL, where proxies
      // would log it.
      auth: (cb) => cb({ token: localStorage.getItem(TOKEN_KEY) ?? '' }),
      reconnection: true,
      reconnectionAttempts: Infinity,
      reconnectionDelay: 800,
      withCredentials: true,
    });
    this.socket = socket;
    socket.on('connect', () => {
      this.renewals = 0;
      console.log('[chat] connected'); // TEMP chat debug
      this.connected.set(true);
      this.emitJoin();
    });
    // An expired token is refused at the handshake (connect_error) or the
    // server drops the socket when it expires; socket.io retries neither.
    socket.on('disconnect', (reason) => {
      console.log('[chat] disconnected:', reason); // TEMP chat debug
      this.connected.set(false);
      if (reason === 'io server disconnect') this.renewAndReconnect();
    });
    socket.on('connect_error', (err) => {
      console.log('[chat] connect_error:', err.message); // TEMP chat debug
      this.connected.set(false);
      if (err.message === 'Unauthorized') this.renewAndReconnect();
    });
    socket.on('message', (message: ChatMessage) => {
      console.log('[chat] received:', message); // TEMP chat debug
      this.incoming.next(message);
    });
  }

  private emitJoin(): void {
    if (this.customOrderId) {
      const id = this.customOrderId;
      this.socket?.emit('join', { customOrderId: id }, (ack: unknown) =>
        console.log('[chat] join', id, '->', ack), // TEMP chat debug
      );
    }
  }

  private renewAndReconnect(): void {
    if (!this.socket || this.renewals >= 3 || !this.refresher.hasRefreshToken()) return;
    this.renewals++;
    this.refresher.refresh().subscribe({
      next: () => this.socket?.connect(),
      error: () => undefined,
    });
  }

  /** Resolves true once the server has accepted the message. */
  send(customOrderId: string, text: string): Promise<boolean> {
    return new Promise((resolve) => {
      if (!this.socket?.connected || !customOrderId || !text.trim()) {
        resolve(false);
        return;
      }
      const timer = window.setTimeout(() => resolve(false), 4000);
      this.socket.emit(
        'message',
        { customOrderId, text: text.trim() },
        (ack?: { ok?: boolean }) => {
          window.clearTimeout(timer);
          console.log('[chat] send ->', ack); // TEMP chat debug
          resolve(!!ack?.ok);
        },
      );
    });
  }

  disconnect(): void {
    this.socket?.disconnect();
    this.socket = undefined;
    this.customOrderId = '';
    this.connected.set(false);
  }
}
