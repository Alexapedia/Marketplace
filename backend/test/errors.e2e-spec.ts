import { Types } from 'mongoose';
import { OrdersService } from '../src/orders/orders.service';
import { bootApp, TestCtx } from './helpers/app';
import { API, auth, shop } from './helpers/shop';

describe('error handling', () => {
  let ctx: TestCtx;
  beforeAll(async () => {
    ctx = await bootApp('errors');
  });
  afterAll(async () => {
    await ctx.close();
  });

  const unwrap = (b: any) => (b && b.data !== undefined ? b.data : b);

  it('confirming the same proposal twice concurrently returns one order and no raw Mongo text', async () => {
    const customer = await shop(ctx).newCustomer();
    const admin = await ctx.createUser({ role: 'super_admin' });
    const created = await ctx
      .http()
      .post(`${API}/custom-orders`)
      .set(auth(customer.token))
      .send({ categoryId: String(new Types.ObjectId()), description: 'custom thing' })
      .expect(201);
    const coId = unwrap(created.body)._id as string;
    const prop = await ctx
      .http()
      .post(`${API}/admin/custom-orders/${coId}/proposals`)
      .set(auth(admin.token))
      .send({ productName: 'Thing', price: 100, quantity: 1 });
    expect([200, 201]).toContain(prop.status);
    const co = await ctx
      .http()
      .get(`${API}/custom-orders/${coId}`)
      .set(auth(customer.token))
      .expect(200);
    const proposalId = String(unwrap(co.body).proposals[0]._id);

    const send = () =>
      ctx
        .http()
        .post(`${API}/custom-orders/${coId}/confirm`)
        .set(auth(customer.token))
        .send({ proposalId, addressId: customer.addressId });
    const [a, b] = await Promise.all([send(), send()]);
    for (const r of [a, b]) {
      expect(JSON.stringify(r.body)).not.toContain('E11000');
      expect([200, 201]).toContain(r.status);
    }
    expect(unwrap(a.body).order._id).toBe(unwrap(b.body).order._id);
  });

  it('createFromProposal called twice returns the first order', async () => {
    const customer = await shop(ctx).newCustomer();
    const customOrderId = String(new Types.ObjectId());
    const params = {
      userId: String(customer.user._id),
      customOrderId,
      productName: 'Thing',
      unitPrice: 50,
      quantity: 2,
    };
    const svc = ctx.app.get(OrdersService);
    const first = await ctx.inTenant(() => svc.createFromProposal(params));
    const second = await ctx.inTenant(() => svc.createFromProposal(params));
    expect(String(second._id)).toBe(String(first._id));
  });

  it('PATCH /notifications/not-an-id/read -> 400', async () => {
    const c = await ctx.createUser();
    await ctx.http().patch(`${API}/notifications/not-an-id/read`).set(auth(c.token)).expect(400);
  });

  it('DELETE /notifications/not-an-id -> 400', async () => {
    const c = await ctx.createUser();
    await ctx.http().delete(`${API}/notifications/not-an-id`).set(auth(c.token)).expect(400);
  });
});
