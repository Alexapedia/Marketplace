import { bootApp, createProduct, TestCtx } from './helpers/app';
import { API, auth, shop } from './helpers/shop';

describe('order status transitions', () => {
  let ctx: TestCtx;
  let s: ReturnType<typeof shop>;
  let admin: { token: string };

  beforeAll(async () => {
    ctx = await bootApp('order_status');
    s = shop(ctx);
    admin = await ctx.createUser({ role: 'super_admin' });
  });
  afterAll(async () => {
    await ctx.close();
  });

  const setStatus = (id: string, body: Record<string, unknown>) =>
    ctx.http().patch(`${API}/admin/orders/${id}/status`).set(auth(admin.token)).send(body);

  async function placeOrder(stock: number, qty: number) {
    const p = await createProduct(ctx, { price: 40, stock });
    const c = await s.newCustomer();
    await s.addToCart(c.token, p._id, qty);
    const res = await s.checkout(c.token, c.addressId).expect(201);
    return { product: p, customer: c, orderId: res.body.data._id as string };
  }

  it('a cancelled order cannot move back to pending', async () => {
    const { orderId } = await placeOrder(5, 1);
    await setStatus(orderId, { status: 'cancelled' }).expect(200);

    const res = await setStatus(orderId, { status: 'pending' });

    expect(res.status).toBe(400);
  });

  it('stock is restored once across cancel, an attempted reopen, and a second cancel', async () => {
    const { product, orderId } = await placeOrder(5, 2);
    await setStatus(orderId, { status: 'cancelled' }).expect(200);

    await setStatus(orderId, { status: 'pending' });
    await setStatus(orderId, { status: 'cancelled' });

    expect((await s.product(product._id)).stock).toBe(5);
  });

  it('customer cancel and admin reject racing restore stock exactly once', async () => {
    const { product, customer, orderId } = await placeOrder(5, 2);

    await Promise.all([
      ctx.http().post(`${API}/orders/${orderId}/cancel`).set(auth(customer.token)),
      setStatus(orderId, { status: 'rejected', rejectionReason: 'No stock in branch' }),
    ]);

    expect((await s.product(product._id)).stock).toBe(5);
  });

  it('skipping forward from pending to preparing is allowed', async () => {
    const { orderId } = await placeOrder(5, 1);

    await setStatus(orderId, { status: 'preparing' }).expect(200);
  });

  it('a delivered order can still be completed but not cancelled', async () => {
    const { orderId } = await placeOrder(5, 1);
    await setStatus(orderId, { status: 'delivered' }).expect(200);

    expect((await setStatus(orderId, { status: 'cancelled' })).status).toBe(400);
    await setStatus(orderId, { status: 'completed' }).expect(200);
  });
});
