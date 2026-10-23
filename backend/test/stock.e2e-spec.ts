import { ProductsService } from '../src/catalog/products.service';
import { bootApp, createProduct, TestCtx } from './helpers/app';
import { shop } from './helpers/shop';

describe('stock reservation', () => {
  let ctx: TestCtx;
  let s: ReturnType<typeof shop>;

  beforeAll(async () => {
    ctx = await bootApp('stock');
    s = shop(ctx);
  });
  afterAll(async () => {
    await ctx.close();
  });

  it('concurrent checkouts for the last unit: exactly one succeeds and stock ends at 0', async () => {
    const p = await createProduct(ctx, { price: 50, stock: 1 });
    const buyers = await Promise.all(
      Array.from({ length: 5 }, async () => {
        const c = await s.newCustomer();
        await s.addToCart(c.token, p._id, 1);
        return c;
      }),
    );

    const results = await Promise.all(buyers.map((b) => s.checkout(b.token, b.addressId)));

    expect(results.map((r) => r.status).sort()).toEqual([201, 400, 400, 400, 400]);
    expect((await s.product(p._id)).stock).toBe(0);
  });

  it('concurrent restores do not lose updates', async () => {
    const p = await createProduct(ctx, { price: 50, stock: 0 });
    const products = ctx.app.get(ProductsService);

    await ctx.inTenant(() =>
      Promise.all(
        Array.from({ length: 10 }, () =>
          products.applyStockDelta([{ productId: String(p._id), quantity: 1 }], 1),
        ),
      ),
    );

    expect((await s.product(p._id)).stock).toBe(10);
  });

  it('variant stock is reserved atomically', async () => {
    const p = await createProduct(ctx, {
      price: 80,
      stock: 10,
      variants: [{ name: 'Gold', sku: 'G-1', stock: 1 }],
    });
    const buyers = await Promise.all(
      Array.from({ length: 5 }, async () => {
        const c = await s.newCustomer();
        await s.addToCart(c.token, p._id, 1, 'Gold');
        return c;
      }),
    );

    const results = await Promise.all(buyers.map((b) => s.checkout(b.token, b.addressId)));

    expect(results.map((r) => r.status).sort()).toEqual([201, 400, 400, 400, 400]);
    const after = await s.product(p._id);
    expect(after.variants[0].stock).toBe(0);
    expect(after.stock).toBe(10);
  });
});
