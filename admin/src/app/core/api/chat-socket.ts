import { Injectable, signal } from '@angular/core';
import { io, Socket } from 'socket.io-client';
import { Subject } from 'rxjs';
import { AuthService } from '../auth/auth.service';
import { TOKEN_KEY, TokenRefresher } from '../auth/token-refresher';
import { ChatMessage } from '../models/models';

export interface ConversationUpdate {
  conversationId?: string;
  customOrderId?: string;
  lastMessage?: string;
  lastMessageAt?: string;
}

@Injectable({ providedIn: 'root' })
export class ChatSocket {
  private socket?: Socket;
  private pendingJoin = '';
  /** Token renewals in a row without a successful connect. */
  private renewals = 0;
  readonly connected = signal(false);
  readonly incoming = new Subject<ChatMessage>();
  readonly conversationUpdated = new Subject<ConversationUpdate>();

  constructor(
    private readonly auth: AuthService,
    private readonly refresher: TokenRefresher,
  ) {}

  connect(): void {
    const token = this.auth.token();
    if (!token) return;
    if (this.socket?.connected) return;
    if (this.socket) {
      this.socket.connect();
      return;
    }
    this.socket = io('/chat', {
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
    this.socket.on('connect', () => {
      this.renewals = 0;
      this.connected.set(true);
      if (this.pendingJoin) {
        this.socket?.emit('join', { conversationId: this.pendingJoin });
      }
    });
    // An expired token is refused at the handshake (connect_error) or the
    // server drops the socket when it expires; socket.io retries neither.
    this.socket.on('disconnect', (reason) => {
      this.connected.set(false);
      if (reason === 'io server disconnect') this.renewAndReconnect();
    });
    this.socket.on('connect_error', (err) => {
      this.connected.set(false);
      if (err.message === 'Unauthorized') this.renewAndReconnect();
    });
    this.socket.on('message', (message: ChatMessage) => this.incoming.next(message));
    this.socket.on('conversation:updated', (payload: ConversationUpdate) =>
      this.conversationUpdated.next(payload),
    );
  }

  private renewAndReconnect(): void {
    if (!this.socket || this.renewals >= 3 || !this.refresher.hasRefreshToken()) return;
    this.renewals++;
    this.refresher.refresh().subscribe({
      next: () => this.socket?.connect(),
      error: () => undefined,
    });
  }

  join(conversationId: string): void {
    this.pendingJoin = conversationId;
    this.connect();
    if (!conversationId || !this.socket) return;
    if (this.socket.connected) {
      this.socket.emit('join', { conversationId });
    }
  }

  send(conversationId: string, text: string): Promise<boolean> {
    return new Promise((resolve) => {
      if (!this.socket?.connected || !conversationId || !text.trim()) {
        resolve(false);
        return;
      }
      const timer = window.setTimeout(() => resolve(false), 4000);
      this.socket.emit(
        'message',
        { conversationId, text: text.trim() },
        (ack?: { ok?: boolean }) => {
          window.clearTimeout(timer);
          resolve(!!ack?.ok);
        },
      );
    });
  }

  disconnect(): void {
    this.socket?.disconnect();
    this.socket = undefined;
    this.pendingJoin = '';
    this.connected.set(false);
  }
}
