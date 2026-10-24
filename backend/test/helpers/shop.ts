import { TestCtx } from './app';

export const API = '/api/v1';
export const auth = (t: string) => ({ Authorization: `Bearer ${t}` });

/** Customer-facing shop actions shared by order/stock/cart suites. */
export function shop(ctx: TestCtx) {
  async function newCustomer() {
    const c = await ctx.createUser();
    const addr = await ctx
      .http()
      .post(`${API}/addresses`)
      .set(auth(c.token))
      .send({ fullName: 'Test', phone: '0100000000', city: 'Cairo', street: '1 Main St' })
      .expect(201);
    return { ...c, addressId: addr.body.data._id as string };
  }

  async function addToCart(token: string, productId: string, quantity: number, variant?: string) {
    const res = await ctx
      .http()
      .post(`${API}/cart/items`)
      .set(auth(token))
      .send({ productId: String(productId), quantity, ...(variant ? { variant } : {}) })
      .expect(201);
    return res.body.data;
  }

  const checkout = (token: string, addressId: string, key?: string) => {
    const r = ctx.http().post(`${API}/orders`).set(auth(token));
    if (key) r.set('Idempotency-Key', key);
    return r.send({ addressId, paymentMethod: 'COD' });
  };

  const product = async (id: string) =>
    (await ctx.inTenant(async () => await ctx.model('Product').findById(id)))!;

  return { newCustomer, addToCart, checkout, product };
}
