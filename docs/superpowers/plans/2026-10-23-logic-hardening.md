# Logic Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the security, money/stock, and reliability defects found in the Phase 1 audit across backend, admin, and mobile, without changing UI or request/response shapes.

**Architecture:** Every backend fix is pinned by an integration test that boots the real Nest app against a throwaway MongoDB database (`placemarket_e2e_<suite>`), so fixes are proven against real Mongoose behavior, including concurrency. Mobile fixes are pinned by `flutter_test` with hand-written fakes (a fake Dio `HttpClientAdapter`). Angular apps have no test runner, so their changes are kept to a minimum and verified with `ng build`.

**Tech Stack:** NestJS 11, Mongoose, Jest + supertest (already installed), MongoDB 7 via the repo's `docker compose up -d mongo`; Flutter 3.9, flutter_bloc 9, dio 5; Angular 21.

**Spec:** Phase 1 audit (findings #1–#20 + Low items), reproduced in the Findings Map below.

## Global Constraints

- No UI/styling changes on this branch (UI work lives on `ui-refresh`).
- No request/response shape changes. Values may change (e.g. order-number format, cart `unitPrice` refreshed), keys may not.
- No new packages. Backend tests use the Docker Mongo; mobile tests use hand-written fakes.
- Tests must never touch the `placemarket` dev database. Each suite uses `placemarket_e2e_<suite>` and drops it in `afterAll`.
- MongoDB is standalone (no replica set): no multi-document transactions. Use atomic conditional updates.
- One problem per commit. Commit messages end with the attribution trailer from the session.
- Every refactor is preceded by a test of current behavior (Phase 3).

## Review Focus

- **Two customers buy the last unit at the same instant** → exactly one order succeeds, stock ends at 0, never negative. (Task 6)
- **Admin and customer cancel/reject the same order at the same instant** → stock is restored exactly once. (Task 7)
- **A mobile user loses signal while the access token is expiring** → they stay logged in and see a network error, not a logout. (Task 15)
- **A file named `x.html` uploaded with `Content-Type: image/png`** → stored as `.png`, served as `image/png` with `nosniff`, never executes. (Task 3)
- **Existing databases already contain duplicate emails/carts/order numbers** → boot does not crash and does not delete data; the unique index is skipped with an error log naming the duplicates. (Tasks 8, 9)

## Findings Map → Tasks

| Audit # | Task | Model |
|---|---|---|
| test harness | 0 | Sonnet |
| characterization | 1, 2 (backend), 14a (mobile) | Sonnet |
| #1 reset token leak | 4 | Opus |
| #2 Firebase takeover / staff 2FA bypass | 5 | Opus |
| #3 upload XSS | 3 | Opus |
| #4 default seed credentials | 10 | Opus |
| #5 stock race / N+1 at checkout | 6 | Opus |
| #6 status ping-pong / double restore | 7 | Opus |
| #7 order number collisions (schema) | 8 | Opus |
| #9 users/carts unique (schema) | 9 | Opus |
| #10 trust proxy / throttling | 11 | Opus |
| #12 CORS + Swagger | 12 | Opus |
| #13 chat socket permissions / token in URL | 13 | Opus |
| #14 patchCustomer role filter | 4b (folded into Task 13b) | Opus |
| #19 2FA lockout | 4 (folded) | Opus |
| #11 mobile logout on refresh failure | 15 | Opus |
| #8 mobile duplicate orders | 16 | Sonnet |
| #17 mobile emit-after-close (many files) | 17 | Opus |
| #16 error leaks (backend) | 18 | Sonnet |
| #16 mobile error mapping | 19 | Sonnet |
| #18 stale cart price | 20 | Opus |
| #15 boot migrations every start | 21 | Opus |
| #20 perf: dashboard cache | 22 | Sonnet |
| Low: cart qty > stock, unvalidated variant | 23 | Sonnet |
| Low: favorites rollback clobbers | 24 | Sonnet |
| Deferred (reasons in Phase 5 report) | — | — |

Deferred, not silently dropped: Angular stale-response races and the duplicated Angular auth code (no test runner; the rules forbid refactoring untested code without approval to add `vitest`); report timezone (needs a business-timezone decision); multi-tab refresh rotation; backend lint reformat (noise-only diff).

---

## Phase 3 — Safety net

### Task 0: Backend integration-test harness

**Files:**
- Create: `backend/test/helpers/app.ts`
- Modify: `backend/test/jest-e2e.json` (add `"maxWorkers": 1`), `backend/package.json` (`test:e2e` adds `--runInBand`)
- Modify: `backend/test/app.e2e-spec.ts` to use the helper (behavior unchanged)

**Interfaces — Produces:**
- `bootApp(suite: string): Promise<TestCtx>` — sets `MONGODB_URI` to `mongodb://127.0.0.1:27017/placemarket_e2e_<suite>` (or `E2E_MONGODB_URI` base), `NODE_ENV=test`, `EXPOSE_RESET_TOKEN=true`, boots `AppModule` with the same global prefix/pipes as `main.ts`.
- `TestCtx = { app, http(): supertest agent, tenantId: string, inTenant<T>(fn: () => Promise<T>): Promise<T>, model<T>(name: string): Model<T>, createUser(opts: { role?: string; email?: string; password?: string; permissions?: never }): Promise<{ user, token, refreshToken? }>, tokenFor(user): string, close(): Promise<void> }`
- `createUser` creates the user directly through the model inside tenant context and signs an `aud: 'tenant'` JWT with the app's `JwtService` (staff skip the TOTP flow this way).
- `createProduct(ctx, { price, stock, variants? }): Promise<ProductDocument>` (published, in first category).

- [ ] Step 1: Write the helper and port `app.e2e-spec.ts` to it.
- [ ] Step 2: Run `cd backend && npm run test:e2e` → Expected: `Tests: 4 passed`.
- [ ] Step 3: Commit `test: add shared backend integration-test harness`.

### Task 1: Characterize auth, uploads, admin access

**Files:** Create `backend/test/auth.e2e-spec.ts`, `backend/test/access.e2e-spec.ts`

Tests (all must PASS against current code):
- `register returns accessToken and refreshToken`; `duplicate email → 409`.
- `customer login returns a session (no 2FA)`.
- `staff login without TOTP returns requires2faSetup + challengeToken + otpauthUrl`; completing `/auth/2fa/setup` with a code from `otpauth` `TOTP.generate()` returns `accessToken` and 10 `backupCodes`.
- `staff login with TOTP returns requires2fa`; `/auth/2fa/verify` with valid code → session; with wrong code → 401.
- `forgot-password for unknown email → generic message`; `refresh rotates`.
- `POST /auth/firebase when Firebase disabled → 501`.
- `customer token on GET /admin/orders → 403`; `no token on GET /orders → 401`.
- `POST /uploads with a PNG → { url } ending in .png and GET of that path → 200`.
- `PATCH /admin/customers/:id {status:'blocked'} as super_admin blocks a customer`.

- [ ] Step 1: Write tests. Step 2: Run → all PASS. Step 3: Commit `test: characterize auth, access control and uploads`.

### Task 2: Characterize checkout, cancel, status flow

**Files:** Create `backend/test/orders.e2e-spec.ts`

Tests (PASS against current code):
- `checkout creates a pending COD order priced from the product, decrements stock, clears the cart` (stock 5, qty 2 → stock 3; `total === price*2 + deliveryFee`).
- `same Idempotency-Key twice returns the same order id and decrements stock once`.
- `checkout of more than stock → 400 out of stock`.
- `customer cancel of pending order restores stock` (3 → 5) and `cancel of delivered order → 400`.
- `admin status pending→accepted→preparing→ready→out_for_delivery→delivered marks COD paid`.
- `admin reject without reason → 400`.

- [ ] Step 1–3 as Task 1. Commit `test: characterize checkout and order status flow`.

### Task 14a: Characterize mobile networking + checkout

**Files:** Create `mobile/test/support/fake_adapter.dart`, `mobile/test/dio_consumer_test.dart`, `mobile/test/checkout_cubit_test.dart`

**Interfaces — Produces:** `FakeAdapter implements HttpClientAdapter` with a queue of `(method, path) → ResponseBody` handlers and a `requests` log; `setUpTestLocator({ApiConsumer?, storage})` that registers fakes in `sl` (GetIt) and resets in `tearDown`.

Tests (PASS against current code):
- `401 then successful refresh retries the request with the new token`.
- `401 then refresh returns 401 clears the session` (storage cleared).
- `checkout submit posts addressId, notes, paymentMethod COD, channel mobile to /orders`.

- [ ] Step 1–3. Run `cd mobile && flutter test`. Commit `test: characterize mobile token refresh and checkout`.

---

## Phase 4 — Fixes (TDD: failing test → watch fail → minimal fix → pass → full suite → commit)

Full suite for backend = `cd backend && npx tsc --noEmit && npm run test:e2e`. For mobile = `cd mobile && flutter analyze --no-fatal-infos && flutter test`. Admin = `cd admin && npx ng build`.

### Task 3: Uploads can't become executable (#3) — Opus

**Files:** Modify `backend/src/uploads/uploads.service.ts`, `backend/src/main.ts`; Test `backend/test/uploads.e2e-spec.ts`
- Test `html file declared as image/png is stored with .png extension` — upload buffer `<script>alert(1)</script>` with filename `x.html`, contentType `image/png` → `url` ends `.png`.
- Test `uploads are served with nosniff and a locked-down CSP` → GET has `x-content-type-options: nosniff` and `content-security-policy` containing `default-src 'none'`.
- Fix: extension comes from `MIME_EXTENSIONS: Record<string, string>` = `{ 'image/jpeg': '.jpg', 'image/png': '.png', 'image/webp': '.webp', 'application/pdf': '.pdf' }`, never from `originalname`. `useStaticAssets(..., { setHeaders })` adds `X-Content-Type-Options: nosniff` and `Content-Security-Policy: default-src 'none'; img-src 'self'; style-src 'unsafe-inline'; sandbox`.
- Commit `fix(uploads): derive file extension from allowed MIME type and lock down served uploads`.

### Task 4: Reset token never returned; 2FA verify honors lockout (#1, #19) — Opus

**Files:** Modify `backend/src/auth/auth.service.ts`, `backend/src/platform/platform-auth.service.ts`; Test `backend/test/auth-hardening.e2e-spec.ts`
- Test `forgot-password does not return resetToken when EXPOSE_RESET_TOKEN is unset` (suite sets `NODE_ENV=staging`, deletes `EXPOSE_RESET_TOKEN`) → body has no `resetToken`.
- Test `staff 2FA verify is rejected while the account is locked` → after 5 wrong codes, a correct code → 403 `Too many attempts`.
- Same lockout test for `/platform/auth/2fa/verify` (seed a platform user via model).
- Fix: `resetToken` only when `config.get('EXPOSE_RESET_TOKEN') === 'true'`; both `verify*` methods throw `ForbiddenException('Too many attempts. Try again later.')` when `lockUntil > now`.
- Two commits (one per problem).

### Task 5: Firebase sign-in can't take over accounts (#2) — Opus

**Files:** Modify `backend/src/auth/auth.service.ts`; Test `backend/test/firebase-auth.e2e-spec.ts` (overrides `FirebaseAdminService` with `{ enabled: true, verifyIdToken: jest.fn() }`)
- Test `unverified Firebase email does not log into an existing account` → existing customer `a@x.com`; token `{uid:'u1', email:'a@x.com', email_verified:false}` → 401 and existing user's `firebaseUid` stays unset.
- Test `verified Firebase email links to an existing customer` → 201, same user id.
- Test `Firebase sign-in is refused for staff accounts` → staff email, verified → 403 `Staff must sign in with email and 2FA`.
- Fix: match by email only when `decoded.email_verified === true`; reject staff roles before `session()`.
- Commit `fix(auth): require verified email for Firebase linking and block staff Firebase sign-in`.

### Task 6: Atomic stock reservation at checkout (#5) — Opus

**Files:** Modify `backend/src/catalog/products.service.ts`, `backend/src/orders/orders.service.ts`; Test `backend/test/stock.e2e-spec.ts`
**Produces:** `ProductsService.reserveStock(items: StockLine[]): Promise<void>` (throws `BadRequestException('Product <name> is out of stock')`, rolls back lines already reserved), `ProductsService.releaseStock(items: StockLine[]): Promise<void>`, `type StockLine = { productId; variant?: string; quantity: number; name?: string }`. `applyStockDelta` is kept as a thin wrapper over these for existing callers.
- Test `two concurrent checkouts for the last unit: exactly one succeeds and stock ends at 0` (two customers, stock 1, `Promise.all` of two POST /orders → one 201, one 400; product stock 0).
- Test `concurrent restores do not lose updates` (stock 0, 10 parallel `releaseStock` of 1 → stock 10).
- Test `variant stock is reserved atomically` (variant stock 1, two concurrent checkouts → one wins, variant stock 0, product stock unchanged).
- Fix: decrement with `updateOne({ _id, stock: { $gte: qty } }, { $inc: { stock: -qty } })`; variants with `updateOne({ _id, variants: { $elemMatch: { name, stock: { $gte: qty } } } }, { $inc: { 'variants.$.stock': -qty } })`; `matchedCount === 0` → out of stock. Release with plain `$inc`. Checkout loads all products with one `find({ _id: { $in } })`, reserves, then creates the order; if order creation fails after retries, releases.
- Commit `fix(orders): reserve stock atomically so concurrent checkouts cannot oversell`.

### Task 7: Order status state machine + restore exactly once (#6) — Opus

**Files:** Create `backend/src/orders/order-status.ts`; Modify `backend/src/orders/orders.service.ts`; Test `backend/test/order-status.e2e-spec.ts`
**Produces:** `canTransition(from: OrderStatus, to: OrderStatus): boolean` — terminal states `completed|cancelled|rejected` allow nothing; otherwise `to` must be later in `pending→accepted→preparing→ready→out_for_delivery→delivered→completed`, or `cancelled`/`rejected` from any non-terminal state before `delivered`.
- Test `cancelled order cannot move back to pending` → 400.
- Test `stock is restored once across cancel → (attempted) pending → cancel` → stock restored once.
- Test `customer cancel and admin reject racing restore stock exactly once` (`Promise.all`, stock check).
- Test `skipping forward pending→preparing is allowed`.
- Fix: status writes use `findOneAndUpdate({ _id, orderStatus: from }, ...)`; if no doc matched → 409 `Order status changed, refresh and retry`; restore runs only for the winning write.
- Commit `fix(orders): enforce status transitions and restore stock exactly once`.

### Task 8: Unique order numbers (#7, schema) — Opus

**Files:** Modify `backend/src/common/utils/mongo.ts`, `backend/src/schemas/order.schema.ts`, `backend/src/orders/orders.service.ts`; Create `backend/src/database/unique-index.ts`; Test `backend/test/order-number.e2e-spec.ts`
**Produces:** `ensureUniqueIndex(model, keys, name, logger): Promise<'created'|'exists'|'skipped-duplicates'>` — counts duplicate groups with an aggregate first; on duplicates logs `name` + up to 5 sample keys and returns `'skipped-duplicates'` (no data deleted).
- Test `order numbers are PM-YYYYMMDD-XXXXXX (6 base36 chars, crypto-random)` and `1000 generated numbers are distinct`.
- Test `the tenantId+orderNumber unique index exists after boot`.
- Test `ensureUniqueIndex skips and reports when duplicates exist` (insert two raw docs with the same key in a scratch collection).
- Fix: generator uses `crypto.randomBytes`; checkout retry loop retries only on duplicate `orderNumber` (11000 with `keyPattern.orderNumber`).
- Commit `fix(orders): make order numbers unique and collision-safe`.

### Task 9: Unique users per tenant email, one cart per user (#9, schema) — Opus

**Files:** Modify `backend/src/schemas/user.schema.ts`, `backend/src/schemas/cart.schema.ts`, `backend/src/cart/cart.service.ts`, `backend/src/auth/auth.service.ts`, `backend/src/seed/seed.service.ts`; Test `backend/test/uniqueness.e2e-spec.ts`
- Test `ten concurrent registrations with one email create exactly one user` (one 201, rest 409 `Email already registered`).
- Test `concurrent first cart reads create one cart`.
- Fix: indexes `{tenantId:1,email:1}` unique and `{tenantId:1,userId:1}` unique via `ensureUniqueIndex` at boot; `getOrCreate` uses `findOneAndUpdate(..., { $setOnInsert: { items: [] } }, { upsert: true, new: true })`; register maps 11000 → `ConflictException('Email already registered')`.
- Commit `fix(users,cart): enforce one account per email and one cart per user`.

### Task 10: No default credentials outside development (#4) — Opus

**Files:** Create `backend/src/seed/seed-credentials.ts`; Modify `backend/src/seed/seed.service.ts`; Test `backend/src/seed/seed-credentials.spec.ts` (unit, `npm test`)
**Produces:** `resolveSeedPassword(env: { NODE_ENV?: string; value?: string }, fallback: string): string | null` → returns `value` if set; returns `fallback` only when `NODE_ENV` is `development`, `test`, or unset; otherwise `null` (seed skips that account and logs an error).
- Tests: `production without SEED_ADMIN_PASSWORD → null`; `staging with default literal 'Admin@123456' → null`; `development without value → fallback`; `explicit strong value → value`.
- Commit `fix(seed): never seed default passwords outside development`.

### Task 11: Real client IPs behind proxies (#10) — Opus

**Files:** Modify `backend/src/main.ts`, `backend/test/helpers/app.ts`, `backend/.env.example`, `backend/.env.staging.example`, `docs/deployment.md`; Test `backend/test/throttle.e2e-spec.ts`
- Test `auth throttle is per client IP behind a trusted proxy`: 10 login attempts with `X-Forwarded-For: 203.0.113.1` → 11th → 429; a request with `X-Forwarded-For: 203.0.113.2` → not 429.
- Fix: `app.set('trust proxy', config.get('TRUST_PROXY') ?? 'loopback, linklocal, uniquelocal')` (private hops only, so a client on the open internet cannot spoof). Helper applies the same.
- Commit `fix(api): trust private proxy hops so rate limits are per client`.

### Task 12: CORS never reflects arbitrary origins with credentials; Swagger off in production (#12) — Opus

**Files:** Create `backend/src/common/utils/cors.ts`; Modify `backend/src/main.ts`; Test `backend/src/common/utils/cors.spec.ts`
**Produces:** `corsOptions(env: { NODE_ENV?: string; CORS_ORIGINS?: string }): { origin: string[] | boolean; credentials: boolean }` — explicit list → `{ origin: list, credentials: true }`; `*` or empty outside production → `{ origin: true, credentials: false }`; production with `*`/empty → `{ origin: false, credentials: false }`.
- Swagger mounted unless `NODE_ENV === 'production' && SWAGGER_ENABLED !== 'true'`.
- Commit `fix(api): stop reflecting any origin with credentials; hide Swagger in production`.

### Task 13: Chat socket enforces staff permissions; tokens leave the URL (#13) — Opus

**Files:** Modify `backend/src/chat/chat.gateway.ts`, `admin/src/app/core/api/chat-socket.ts`; Test `backend/test/chat-gateway.e2e-spec.ts`
- Tests call `gateway.join/message` with a fake socket (`{ data: { user }, rooms: new Set(), join: jest.fn(), leave: jest.fn(), emit: jest.fn() }`):
  - `staff without chats.read cannot join a conversation` → `{ ok: false }`, `join` not called.
  - `staff without chats.write cannot post` → `{ ok: false }`.
  - `super_admin can join and post`.
  - `socket is disconnected when the access token expires` (connect with token `exp` 1s ahead, fake timers → `disconnect` called).
- Fix: permission check helper in gateway (super_admin bypass); `setTimeout` to disconnect at `exp`. Admin client: remove `query: { token }`, use `auth: (cb) => cb({ token: this.auth.token() })` so reconnects carry the fresh token. Verify admin with `npx ng build`.
- Commit backend and admin separately.

### Task 13b: Customer status changes can't target staff (#14) — Opus

**Files:** Modify `backend/src/admin/admin.service.ts`; Test add to `backend/test/access.e2e-spec.ts`
- Test `PATCH /admin/customers/:staffId → 404` and the staff stays active.
- Fix: filter `{ _id, role: 'customer' }`.
- Commit `fix(admin): customer status endpoint only affects customers`.

### Task 15: Mobile keeps the session on transient refresh failures (#11) — Opus

**Files:** Modify `mobile/lib/core/connection/implementation/dio_consumer.dart`; Test `mobile/test/dio_consumer_test.dart`
- Test `refresh timing out keeps tokens and returns a network error` (adapter throws `DioExceptionType.connectionTimeout` on `/auth/refresh`) → storage still has both tokens, result is `Left`, no navigation.
- Test `refresh 500 keeps the session`.
- Existing test `refresh 401 clears the session` still passes.
- Fix: `_refreshAccessToken` returns a tri-state (`_RefreshResult.renewed(token) | .rejected | .unavailable`); only `.rejected` (HTTP 400/401/403 from `/auth/refresh`, or no refresh token stored) calls `_handleUnauthorized`.
- Commit `fix(mobile): do not log users out when token refresh fails for network reasons`.

### Task 16: Mobile checkout can't create duplicate orders (#8) — Sonnet

**Files:** Modify `mobile/lib/modules/pages/checkout/controller/check_out_cubit.dart`, `mobile/lib/core/connection/interfaces/api_consumer.dart` + `dio_consumer.dart` (optional `headers` param on `post`); Test `mobile/test/checkout_cubit_test.dart`
- Test `submit sends an Idempotency-Key header that stays the same across retries of one checkout`.
- Test `a second submit while the first is in flight sends nothing`.
- Fix: key generated once per cubit (`mobile-<epochMs>-<random>`), guard on `state.status == RequestStatus.loading`.
- Commit `fix(mobile): send idempotency key and block double checkout submits`.

### Task 17: Cubits never emit after close (#17) — Opus (many files)

**Files:** Create `mobile/lib/core/utils/functions/safe_emit.dart`; Modify the 18 cubits listed in the audit (add `with SafeEmitMixin`); Test `mobile/test/safe_emit_test.dart`
**Produces:** `mixin SafeEmitMixin<S> on BlocBase<S> { @override void emit(S state) { if (!isClosed) super.emit(state); } }`
- Test `a cubit with SafeEmitMixin ignores emits after close` and `a real cubit (CategoriesCubit) closed mid-load does not throw`.
- Commit `fix(mobile): ignore late emits from cubits closed mid-request`.

### Task 18: Backend errors don't leak internals (#16) — Sonnet

**Files:** Modify `backend/src/orders/orders.service.ts` (`createFromProposal`), `backend/src/notifications/notifications.service.ts`; Test `backend/test/errors.e2e-spec.ts`
- Test `confirming the same proposal twice concurrently returns one order and no raw Mongo text` (both 2xx, same order id; no body contains `E11000`).
- Test `PATCH /notifications/not-an-id/read → 400 Invalid id`.
- Fix: on 11000 for `custom-order:<id>` return the existing order; rethrow `HttpException`s; otherwise generic `BadRequestException('Could not create order from proposal')`. Notifications use `toObjectId`.
- Commit `fix(api): return idempotent proposal confirmations and stop leaking driver errors`.

### Task 19: Mobile surfaces server messages for 4xx (#16) — Sonnet

**Files:** Modify `dio_consumer.dart` (`handleDioError`); Test `mobile/test/dio_consumer_test.dart`
- Test `404 with a server message returns that message`; `409 returns the server message`; `503 store suspended returns the server message`.
- Commit `fix(mobile): show the server's error message for client errors`.

### Task 20: Cart shows the price that will be charged (#18) — Opus

**Files:** Modify `backend/src/cart/cart.service.ts`; Test add to `backend/test/orders.e2e-spec.ts`
- Test `GET /cart reflects a product price change made after the item was added` and `unpublished products are flagged unavailable without changing the response keys` (item kept; existing `unitPrice` key refreshed).
- Fix: `get()` refreshes `unitPrice` from `effectivePrice` for each line (one `find({ _id: { $in } })`), saves only if changed.
- Commit `fix(cart): keep cart prices in sync with current product prices`.

### Task 21: Boot migrations run once (#15) — Opus

**Files:** Modify `backend/src/seed/seed.service.ts`, `backend/src/orders/orders.service.ts`; Test `backend/test/boot.e2e-spec.ts`
**Produces:** `_migrations` collection marker `{ _id: 'boot-v1', appliedAt }` (raw collection, no schema).
- Test `second boot skips backfill and legacy index drops` (spy on `connection.db.collection('users').dropIndex` via a second app boot against the same DB).
- Commit `perf(boot): run one-time migrations once instead of on every start`.

### Task 22: Dashboard aggregates cached briefly (#20) — Sonnet

**Files:** Modify `backend/src/admin/admin.service.ts`; Test `backend/test/dashboard.e2e-spec.ts`
- Test `two dashboard calls within 30s run the aggregation once` (spy on `orderModel.aggregate`), `cache is per tenant`.
- Fix: in-memory `Map<tenantId, { at, value }>` with 30 s TTL.
- Commit `perf(admin): cache dashboard aggregates for 30 seconds per tenant`.

### Task 23: Cart quantity and variant validation (Low) — Sonnet

**Files:** Modify `backend/src/cart/cart.service.ts`; Test add to `backend/test/orders.e2e-spec.ts`
- Tests `adding past available stock → 400 Insufficient stock` (existing 2 + add 2 with stock 3), `updating quantity past stock → 400`, `unknown variant on a product that has variants → 400 Unknown variant`.
- Commit `fix(cart): validate cumulative quantity and variant names`.

### Task 24: Favorites rollback only undoes its own toggle (Low) — Sonnet

**Files:** Modify `mobile/lib/config/app_controller/app_controller_cubit.dart`; Test `mobile/test/favorites_toggle_test.dart`
- Test `failure toggling A does not undo a successful toggle of B`.
- Commit `fix(mobile): favorite rollback reverts only the failed product`.

---

## Phase 5

Whole-branch review on Opus, full suites green, report files changed, coverage, risks, deferred items, and model per task.
