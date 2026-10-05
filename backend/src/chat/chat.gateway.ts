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
  }

  async handleConnection(client: Socket) {
    try {
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
      const user = await this.auth.userFromToken(token);
      client.data.user = user;
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

  handleDisconnect() {
    return;
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
