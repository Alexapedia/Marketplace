import { Logger } from '@nestjs/common';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { SkipThrottle } from '@nestjs/throttler';
import { Server, Socket } from 'socket.io';
import { AuthService } from '../auth/auth.service';
import { Public } from '../common/decorators/public.decorator';
import type { AuthUser } from '../common/types/auth-user';
import { CustomOrdersService } from '../custom-orders/custom-orders.service';
import { ChatRealtimeService } from './chat-realtime.service';
import { TenantContext } from '../tenant/tenant.context';

@SkipThrottle()
@Public()
@WebSocketGateway({
  namespace: '/chat',
  path: '/socket.io',
  cors: { origin: true, credentials: true },
  transports: ['websocket', 'polling'],
})
export class ChatGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  private readonly logger = new Logger(ChatGateway.name);

  @WebSocketServer()
  server: Server;

  constructor(
    private readonly auth: AuthService,
    private readonly customOrders: CustomOrdersService,
    private readonly realtime: ChatRealtimeService,
  ) {}

  afterInit(server: Server) {
    this.realtime.attach(server);
    // Authenticate during the handshake: the client only gets `connect` once
    // the user is known, so a `join` sent straight away is never refused.
    server.use((client, next) => {
      void this.authMiddleware(client, next);
    });
  }

  /** Handshake middleware: sets `client.data.user`, or fails with connect_error. */
  async authMiddleware(client: Socket, next: (err?: Error) => void) {
    try {
      await this.authenticate(client);
      next();
    } catch (err) {
      this.logger.warn(`Chat socket rejected: ${(err as Error).message}`);
      next(new Error('Unauthorized'));
    }
  }

  private async authenticate(client: Socket) {
    const header = client.handshake.headers.authorization;
    const fromHeader =
      typeof header === 'string' && header.startsWith('Bearer ')
        ? header.slice(7)
        : '';
    const token =
      (client.handshake.auth?.token as string | undefined) ||
      (client.handshake.query?.token as string | undefined) ||
      fromHeader;
    if (!token) {
      throw new Error('Missing token');
    }
    client.data.user = await this.auth.userFromToken(token);
    client.data.token = token;
  }

  async handleConnection(client: Socket) {
    try {
      if (!client.data.user) {
        await this.authenticate(client);
      }
      const user = client.data.user as AuthUser;
      this.expireWithToken(client, client.data.token as string);
      if (user.type === 'staff') {
        await client.join(`staff:${user.tenantId}`);
      }
      this.logger.debug(`Chat connected ${user.userId} (${user.role})`);
    } catch (err) {
      this.logger.warn(`Chat socket rejected: ${(err as Error).message}`);
      client.emit('error', { message: 'Unauthorized' });
      client.disconnect(true);
    }
  }

  handleDisconnect(client?: Socket) {
    const timer = client?.data?.expiryTimer as NodeJS.Timeout | undefined;
    if (timer) clearTimeout(timer);
  }

  /** Auth is checked once at connect, so drop the socket when its token expires. */
  private expireWithToken(client: Socket, token: string) {
    const exp = tokenExpiry(token);
    if (!exp) return;
    const timer = setTimeout(
      () => {
        client.emit('error', { message: 'Session expired' });
        client.disconnect(true);
      },
      Math.max(0, exp * 1000 - Date.now()),
    );
    timer.unref?.();
    client.data.expiryTimer = timer;
  }

  /** Staff need chat permissions; customers are limited to their own chats by the service. */
  private allowed(user: AuthUser, permission: 'chats.read' | 'chats.write') {
    return (
      user.type !== 'staff' ||
      user.role === 'super_admin' ||
      (user.permissions ?? []).includes(permission)
    );
  }

  @SubscribeMessage('join')
  async join(
    @ConnectedSocket() client: Socket,
    @MessageBody()
    body: { customOrderId?: string; conversationId?: string },
  ) {
    try {
      const user = this.userOf(client);
      if (!user) return { ok: false };
      if (!this.allowed(user, 'chats.read')) {
        client.emit('error', { message: 'Insufficient permissions' });
        return { ok: false };
      }
      return TenantContext.run({ kind: 'tenant', tenantId: user.tenantId }, async () => {
        const convo = await this.customOrders.resolveConversation(user, body);
        for (const room of client.rooms) {
          if (room.startsWith('conversation:')) {
            await client.leave(room);
          }
        }
        await client.join(`conversation:${String(convo._id)}`);
        return { ok: true, conversationId: String(convo._id) };
      });
    } catch (err) {
      client.emit('error', { message: (err as Error).message });
      return { ok: false };
    }
  }

  @SubscribeMessage('message')
  async message(
    @ConnectedSocket() client: Socket,
    @MessageBody()
    body: { customOrderId?: string; conversationId?: string; text?: string },
  ) {
    try {
      const user = this.userOf(client);
      if (!user) return { ok: false };
      if (!this.allowed(user, 'chats.write')) {
        client.emit('error', { message: 'Insufficient permissions' });
        return { ok: false, message: 'Insufficient permissions' };
      }
      const text = (body.text || '').trim();
      if (!text) return { ok: false, message: 'text required' };
      return TenantContext.run({ kind: 'tenant', tenantId: user.tenantId }, async () => {
        if (body.customOrderId) {
          await this.customOrders.postMessage(user, body.customOrderId, { text });
          return { ok: true };
        }
        if (body.conversationId) {
          await this.customOrders.postChatMessage(user, body.conversationId, {
            text,
          });
          return { ok: true };
        }
        return { ok: false, message: 'customOrderId or conversationId required' };
      });
    } catch (err) {
      client.emit('error', { message: (err as Error).message });
      return { ok: false };
    }
  }

  private userOf(client: Socket): AuthUser | undefined {
    return client.data.user as AuthUser | undefined;
  }
}

/** Reads `exp` (seconds) from an already-verified JWT without re-verifying. */
function tokenExpiry(token: string): number | undefined {
  try {
    const payload = JSON.parse(
      Buffer.from(token.split('.')[1], 'base64url').toString('utf8'),
    ) as { exp?: number };
    return typeof payload.exp === 'number' ? payload.exp : undefined;
  } catch {
    return undefined;
  }
}
