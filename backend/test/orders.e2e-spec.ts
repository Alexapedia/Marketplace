import { bootApp, createProduct, TestCtx } from './helpers/app';

describe('orders (characterization)', () => {
  let ctx: TestCtx;
  let admin: { token: string };
  const api = '/api/v1';

  beforeAll(async () => {
    ctx = await bootApp('orders');
    admin = await ctx.createUser({ role: 'super_admin' });
  });
  afterAll(async () => {
    await ctx.close();
  });

  const auth = (t: string) => ({ Authorization: `Bearer ${t}` });

  async function newCustomer() {
    const c = await ctx.createUser();
    const addr = await ctx
      .http()
      .post(`${api}/addresses`)
      .set(auth(c.token))
      .send({ fullName: 'Test', phone: '0100000000', city: 'Cairo', street: '1 Main St' })
      .expect(201);
    return { ...c, addressId: addr.body.data._id as string };
  }

  async function addToCart(token: string, productId: string, quantity: number) {
    const res = await ctx
      .http()
      .post(`${api}/cart/items`)
      .set(auth(token))
      .send({ productId: String(productId), quantity })
      .expect(201);
    return res.body.data;
  }

  const checkout = (token: string, addressId: string, key?: string) => {
    const r = ctx.http().post(`${api}/orders`).set(auth(token));
    if (key) r.set('Idempotency-Key', key);
    return r.send({ addressId, paymentMethod: 'COD' });
  };

  const stockOf = async (id: string) =>
    (await ctx.inTenant(async () => await ctx.model('Product').findById(id)))!.stock;

  const setStatus = (id: string, body: any) =>
    ctx
      .http()
      .patch(`${api}/admin/orders/${id}/status`)
      .set(auth(admin.token))
      .send(body);

  it('checkout creates pending COD order, decrements stock, clears cart', async () => {
    const c = await newCustomer();
    const p = await createProduct(ctx, { price: 100, stock: 5 });
    await addToCart(c.token, p._id, 2);

    const res = await checkout(c.token, c.addressId).expect(201);
    const order = res.body.data;
    expect(order.orderStatus).toBe('pending');
    expect(order.paymentMethod).toBe('COD');
    expect(order.subtotal).toBe(200);
    expect(order.total).toBe(order.subtotal + order.deliveryFee);
    expect(await stockOf(p._id)).toBe(3);

    const cart = await ctx.http().get(`${api}/cart`).set(auth(c.token)).expect(200);
    expect(cart.body.data.items).toEqual([]);
  });

  it('same Idempotency-Key returns same order and decrements stock once', async () => {
    const c = await newCustomer();
    const p = await createProduct(ctx, { price: 100, stock: 5 });
    await addToCart(c.token, p._id, 2);

    const first = await checkout(c.token, c.addressId, 'key-1').expect(201);
    const second = await checkout(c.token, c.addressId, 'key-1').expect(201);
    expect(second.body.data._id).toBe(first.body.data._id);
    expect(await stockOf(p._id)).toBe(3);
  });

  it('raising cart qty past stock via PATCH is rejected and the line is unchanged', async () => {
    const c = await newCustomer();
    const p = await createProduct(ctx, { price: 100, stock: 1 });
    const cart = await addToCart(c.token, p._id, 1);
    const itemId = cart.items[0]._id;
    await ctx
      .http()
      .patch(`${api}/cart/items/${itemId}`)
      .set(auth(c.token))
      .send({ quantity: 2 })
      .expect(400);

    const after = await ctx.http().get(`${api}/cart`).set(auth(c.token)).expect(200);
    expect(after.body.data.items[0].quantity).toBe(1);
    expect(await stockOf(p._id)).toBe(1);
  });

  it('customer cancel of pending order restores stock; delivered cannot be cancelled', async () => {
    const c = await newCustomer();
    const p = await createProduct(ctx, { price: 100, stock: 5 });
    await addToCart(c.token, p._id, 2);
    const o1 = (await checkout(c.token, c.addressId).expect(201)).body.data;
    expect(await stockOf(p._id)).toBe(3);

    const cancelled = await ctx
      .http()
      .post(`${api}/orders/${o1._id}/cancel`)
      .set(auth(c.token))
      .expect(201);
    expect(cancelled.body.data.orderStatus).toBe('cancelled');
    expect(await stockOf(p._id)).toBe(5);

    await addToCart(c.token, p._id, 1);
    const o2 = (await checkout(c.token, c.addressId).expect(201)).body.data;
    for (const status of ['accepted', 'preparing', 'ready', 'out_for_delivery', 'delivered']) {
      await setStatus(o2._id, { status }).expect(200);
    }
    await ctx
      .http()
      .post(`${api}/orders/${o2._id}/cancel`)
      .set(auth(c.token))
      .expect(400);
  });

  it('admin status flow to delivered marks COD paid', async () => {
    const c = await newCustomer();
    const p = await createProduct(ctx, { price: 50, stock: 5 });
    await addToCart(c.token, p._id, 1);
    const o = (await checkout(c.token, c.addressId).expect(201)).body.data;
    expect(o.paymentStatus).toBe('pending');

    let last: any;
    for (const status of ['accepted', 'preparing', 'ready', 'out_for_delivery', 'delivered']) {
      last = await setStatus(o._id, { status }).expect(200);
      expect(last.body.data.orderStatus).toBe(status);
    }
    expect(last.body.data.paymentStatus).toBe('paid');
  });

  it('admin reject without rejectionReason is 400', async () => {
    const c = await newCustomer();
    const p = await createProduct(ctx, { price: 50, stock: 5 });
    await addToCart(c.token, p._id, 1);
    const o = (await checkout(c.token, c.addressId).expect(201)).body.data;
    await setStatus(o._id, { status: 'rejected' }).expect(400);
  });
});
