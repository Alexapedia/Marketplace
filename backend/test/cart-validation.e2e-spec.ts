import { bootApp, createProduct, TestCtx } from './helpers/app';
import { API, auth, shop } from './helpers/shop';

describe('cart validation', () => {
  let ctx: TestCtx;

  beforeAll(async () => {
    ctx = await bootApp('cart_validation');
  });
  afterAll(async () => {
    await ctx.close();
  });

  const add = (token: string, body: Record<string, unknown>) =>
    ctx.http().post(`${API}/cart/items`).set(auth(token)).send(body);

  it('adding past available stock is rejected', async () => {
    const c = await ctx.createUser();
    const p = await createProduct(ctx, { price: 10, stock: 3 });
    await add(c.token, { productId: String(p._id), quantity: 2 }).expect(201);
    const res = await add(c.token, { productId: String(p._id), quantity: 2 }).expect(400);
    expect(JSON.stringify(res.body)).toContain('Insufficient stock');
    const cart = await ctx.http().get(`${API}/cart`).set(auth(c.token)).expect(200);
    expect(cart.body.data.items[0].quantity).toBe(2);
  });

  it('updating quantity past stock is rejected', async () => {
    const c = await ctx.createUser();
    const p = await createProduct(ctx, { price: 10, stock: 3 });
    const cart = await shop(ctx).addToCart(c.token, p._id, 1);
    const itemId = cart.items[0]._id;
    const patch = (quantity: number) =>
      ctx.http().patch(`${API}/cart/items/${itemId}`).set(auth(c.token)).send({ quantity });
    const res = await patch(5).expect(400);
    expect(JSON.stringify(res.body)).toContain('Insufficient stock');
    await patch(3).expect(200);
  });

  it('an unknown variant on a product with variants is rejected', async () => {
    const c = await ctx.createUser();
    const p = await createProduct(ctx, { price: 10, stock: 0, variants: [{ name: 'Gold', stock: 5 }] });
    const res = await add(c.token, { productId: String(p._id), quantity: 1, variant: 'Purple' }).expect(400);
    expect(JSON.stringify(res.body)).toContain('Unknown variant');
    await add(c.token, { productId: String(p._id), quantity: 1, variant: 'Gold' }).expect(201);
  });

  it('a variant can be referenced by sku', async () => {
    const c = await ctx.createUser();
    const p = await createProduct(ctx, {
      price: 10,
      stock: 0,
      variants: [{ name: 'Gold', sku: 'G-1', stock: 5 }],
    });
    await add(c.token, { productId: String(p._id), quantity: 1, variant: 'G-1' }).expect(201);
  });
});
