import { bootApp, createProduct, TestCtx } from './helpers/app';
import { API, auth, shop } from './helpers/shop';

describe('cart prices', () => {
  let ctx: TestCtx;
  let s: ReturnType<typeof shop>;

  beforeAll(async () => {
    ctx = await bootApp('cart_prices');
    s = shop(ctx);
  });
  afterAll(async () => {
    await ctx.close();
  });

  const setProduct = (id: string, patch: Record<string, unknown>) =>
    ctx.inTenant(async () => ctx.model('Product').updateOne({ _id: id }, { $set: patch }));

  it('GET /cart shows the current price after a price change', async () => {
    const { token } = await ctx.createUser();
    const p = await createProduct(ctx, { price: 100, stock: 5 });
    await s.addToCart(token, p._id, 1);

    await setProduct(p._id, { price: 150 });
    const res = await ctx.http().get(`${API}/cart`).set(auth(token)).expect(200);

    expect(res.body.data.items[0].unitPrice).toBe(150);
  });

  it('GET /cart reflects a sale price started after the item was added', async () => {
    const { token } = await ctx.createUser();
    const p = await createProduct(ctx, { price: 200, stock: 5 });
    await s.addToCart(token, p._id, 2);

    await setProduct(p._id, { salePrice: 120 });
    const res = await ctx.http().get(`${API}/cart`).set(auth(token)).expect(200);

    expect(res.body.data.items[0].unitPrice).toBe(120);
  });

  it('the cart total matches what checkout charges', async () => {
    const c = await s.newCustomer();
    const p = await createProduct(ctx, { price: 80, stock: 5 });
    await s.addToCart(c.token, p._id, 2);
    await setProduct(p._id, { price: 95 });

    const cart = await ctx.http().get(`${API}/cart`).set(auth(c.token)).expect(200);
    const shown = cart.body.data.items.reduce(
      (sum: number, i: { unitPrice: number; quantity: number }) => sum + i.unitPrice * i.quantity,
      0,
    );
    const order = await s.checkout(c.token, c.addressId).expect(201);

    expect(order.body.data.subtotal).toBe(shown);
  });
});
