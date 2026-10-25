import { bootApp, createProduct, TestCtx } from './helpers/app';
import { API, auth, shop } from './helpers/shop';

describe('delivery confirmation code', () => {
  let ctx: TestCtx;
  let s: ReturnType<typeof shop>;
  let admin: { token: string };

  beforeAll(async () => {
    ctx = await bootApp('delivery_code');
    s = shop(ctx);
    admin = await ctx.createUser({ role: 'admin' });
  });
  afterAll(async () => {
    await ctx.close();
  });

  async function placeOrder() {
    const p = await createProduct(ctx, { price: 40, stock: 10 });
    const c = await s.newCustomer();
    await s.addToCart(c.token, p._id, 1);
    const res = await s.checkout(c.token, c.addressId).expect(201);
    return { customer: c, orderId: res.body.data._id as string };
  }

  const customerOrder = (token: string, id: string) =>
    ctx.http().get(`${API}/orders/${id}`).set(auth(token)).expect(200);
  const confirm = (token: string, id: string, code: string) =>
    ctx
      .http()
      .post(`${API}/admin/orders/${id}/confirm-delivery`)
      .set(auth(token))
      .send({ code });
  const setStatus = (id: string, status: string) =>
    ctx
      .http()
      .patch(`${API}/admin/orders/${id}/status`)
      .set(auth(admin.token))
      .send({ status });

  it('the customer sees a 6-digit code on their order', async () => {
    const { customer, orderId } = await placeOrder();
    const res = await customerOrder(customer.token, orderId);
    expect(res.body.data.deliveryCode).toMatch(/^\d{6}$/);
  });

  it('staff never see the code, in the list or the order', async () => {
    const { orderId } = await placeOrder();
    const one = await ctx
      .http()
      .get(`${API}/admin/orders/${orderId}`)
      .set(auth(admin.token))
      .expect(200);
    expect(one.body.data.deliveryCode).toBeUndefined();
    const list = await ctx
      .http()
      .get(`${API}/admin/orders`)
      .set(auth(admin.token))
      .expect(200);
    for (const o of list.body.data) expect(o.deliveryCode).toBeUndefined();
  });

  it('the right code completes the order and marks cash on delivery paid', async () => {
    const { customer, orderId } = await placeOrder();
    await setStatus(orderId, 'out_for_delivery').expect(200);
    const code = (await customerOrder(customer.token, orderId)).body.data
      .deliveryCode as string;

    const res = await confirm(admin.token, orderId, code).expect(201);

    expect(res.body.data.orderStatus).toBe('completed');
    expect(res.body.data.paymentStatus).toBe('paid');
    expect(res.body.data.deliveryCode).toBeUndefined();
  });

  it('a wrong code is refused and the order stays as it was', async () => {
    const { customer, orderId } = await placeOrder();
    await setStatus(orderId, 'out_for_delivery').expect(200);
    const code = (await customerOrder(customer.token, orderId)).body.data
      .deliveryCode as string;
    const wrong = code === '000000' ? '111111' : '000000';

    expect((await confirm(admin.token, orderId, wrong)).status).toBe(400);
    const after = await customerOrder(customer.token, orderId);
    expect(after.body.data.orderStatus).toBe('out_for_delivery');
  });

  it('only admins can confirm a delivery', async () => {
    const { customer, orderId } = await placeOrder();
    const code = (await customerOrder(customer.token, orderId)).body.data
      .deliveryCode as string;
    const manager = await ctx.createUser({ role: 'order_manager' });

    expect((await confirm(manager.token, orderId, code)).status).toBe(403);
    expect((await confirm(customer.token, orderId, code)).status).toBe(403);
  });

  it('delivered and completed can no longer be set without the code', async () => {
    const { orderId } = await placeOrder();
    expect((await setStatus(orderId, 'delivered')).status).toBe(400);
    expect((await setStatus(orderId, 'completed')).status).toBe(400);
  });

  it('a completed or cancelled order cannot be confirmed again', async () => {
    const { customer, orderId } = await placeOrder();
    const code = (await customerOrder(customer.token, orderId)).body.data
      .deliveryCode as string;
    await setStatus(orderId, 'cancelled').expect(200);
    expect((await confirm(admin.token, orderId, code)).status).toBe(400);
  });

  it('an order placed before codes existed gets one when the customer opens it', async () => {
    const { customer, orderId } = await placeOrder();
    await ctx.inTenant(async () => {
      await ctx
        .model('Order')
        .updateOne({ _id: orderId }, { $unset: { deliveryCode: 1 } });
    });
    const res = await customerOrder(customer.token, orderId);
    expect(res.body.data.deliveryCode).toMatch(/^\d{6}$/);
    const again = await customerOrder(customer.token, orderId);
    expect(again.body.data.deliveryCode).toBe(res.body.data.deliveryCode);
  });
});
