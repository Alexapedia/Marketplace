import { Types } from 'mongoose';
import { AuthService } from '../src/auth/auth.service';
import { ChatGateway } from '../src/chat/chat.gateway';
import { bootApp, TestCtx } from './helpers/app';

type FakeSocket = {
  data: Record<string, unknown>;
  rooms: Set<string>;
  handshake: { headers: Record<string, string>; auth: Record<string, string>; query: Record<string, string> };
  join: jest.Mock;
  leave: jest.Mock;
  emit: jest.Mock;
  disconnect: jest.Mock;
};

const fakeSocket = (token = ''): FakeSocket => ({
  data: {},
  rooms: new Set(),
  handshake: { headers: {}, auth: { token }, query: {} },
  join: jest.fn(async () => undefined),
  leave: jest.fn(async () => undefined),
  emit: jest.fn(),
  disconnect: jest.fn(),
});

describe('chat gateway authorization', () => {
  let ctx: TestCtx;
  let gateway: ChatGateway;
  let conversationId: string;

  beforeAll(async () => {
    ctx = await bootApp('chat_gateway');
    gateway = ctx.app.get(ChatGateway);
    const customer = await ctx.createUser();
    const convo = await ctx.inTenant(async () =>
      ctx.model('Conversation').create({
        userId: customer.user._id,
        lastMessageAt: new Date(),
        unreadByCustomer: 0,
        unreadByStaff: 0,
      }),
    );
    conversationId = String(convo._id);
  });
  afterAll(async () => {
    await ctx.close();
  });

  async function connected(role: string) {
    const { token } = await ctx.createUser({ role });
    const socket = fakeSocket(token);
    await gateway.handleConnection(socket as never);
    expect(socket.disconnect).not.toHaveBeenCalled();
    return socket;
  }

  it('staff without chats.read cannot join a conversation', async () => {
    const socket = await connected('product_manager');

    const res = await gateway.join(socket as never, { conversationId });

    expect(res).toEqual({ ok: false });
    expect(socket.join).not.toHaveBeenCalledWith(`conversation:${conversationId}`);
  });

  it('staff without chats.write cannot post', async () => {
    const socket = await connected('product_manager');

    const res = await gateway.message(socket as never, { conversationId, text: 'hello' });

    expect(res.ok).toBe(false);
    const count = await ctx.inTenant(async () =>
      ctx.model('Message').countDocuments({ conversationId, text: 'hello' }),
    );
    expect(count).toBe(0);
  });

  it('support agents with chat permissions can join and post', async () => {
    const socket = await connected('support_agent');

    expect(await gateway.join(socket as never, { conversationId })).toMatchObject({ ok: true });
    expect(await gateway.message(socket as never, { conversationId, text: 'hi there' })).toEqual({
      ok: true,
    });
  });

  it('authenticates in the handshake, so the client only sees connect once it is known', async () => {
    const { token, user } = await ctx.createUser();
    const socket = fakeSocket(token);
    const next = jest.fn();

    await gateway.authMiddleware(socket as never, next);

    expect(next).toHaveBeenCalledWith();
    expect((socket.data.user as { userId: string }).userId).toBe(String(user._id));
  });

  it('rejects a bad token in the handshake with connect_error', async () => {
    const socket = fakeSocket('not-a-token');
    const next = jest.fn();

    await gateway.authMiddleware(socket as never, next);

    expect(next).toHaveBeenCalledWith(expect.objectContaining({ message: 'Unauthorized' }));
    expect(socket.data.user).toBeUndefined();
  });

  it('a customer joins their custom order chat right after connecting (mobile flow)', async () => {
    const { token, user } = await ctx.createUser();
    const order = await ctx.inTenant(async () =>
      ctx.model('CustomOrder').create({
        userId: user._id,
        categoryId: new Types.ObjectId(),
        fields: {},
      }),
    );
    const socket = fakeSocket(token);
    await gateway.authMiddleware(socket as never, jest.fn());
    await gateway.handleConnection(socket as never);

    const res = await gateway.join(socket as never, { customOrderId: String(order._id) });

    expect(res).toMatchObject({ ok: true });
    expect(socket.join).toHaveBeenCalledWith(`conversation:${(res as { conversationId: string }).conversationId}`);
  });

  it('the socket is disconnected when its access token expires', async () => {
    const { user } = await ctx.createUser({ role: 'support_agent' });
    const jwt = (ctx.app.get(AuthService) as unknown as { jwt: { sign: Function } }).jwt;
    const shortToken = jwt.sign(
      {
        sub: String(user._id),
        email: user.email,
        role: user.role,
        type: 'staff',
        tenantId: ctx.tenantId,
        aud: 'tenant',
      },
      { expiresIn: 1 },
    );
    const socket = fakeSocket(shortToken);

    await gateway.handleConnection(socket as never);
    expect(socket.disconnect).not.toHaveBeenCalled();
    await new Promise((r) => setTimeout(r, 1600));

    expect(socket.disconnect).toHaveBeenCalledWith(true);
  });
});
