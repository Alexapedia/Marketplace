# PlaceMarket API v1

Base URL: `http://localhost:3000/api/v1`

## Envelope

Success:

```json
{ "success": true, "data": {}, "message": "optional", "meta": { "page": 1, "limit": 20, "total": 0, "totalPages": 0 } }
```

Error:

```json
{ "success": false, "statusCode": 400, "message": "Validation failed", "errors": {} }
```

Auth: `Authorization: Bearer <jwt>`

JWT payload: `{ sub, email, role, type }` where `type` is `customer` or `staff`.

Roles: `customer`, `super_admin`, `admin`, `support_agent`, `order_manager`, `product_manager`, `marketing_manager`

Permissions are stored on roles and checked via `@Permissions('orders.write')`.

## Localized fields

`name` / `description` objects: `{ "en": "...", "ar": "..." }`

## Auth (public)

| Method | Path | Body |
|---|---|---|
| POST | `/auth/register` | `{ name, email, password, phone? }` |
| POST | `/auth/login` | `{ email, password }` |
| POST | `/auth/forgot-password` | `{ email }` |
| POST | `/auth/reset-password` | `{ token, password }` |
| POST | `/auth/firebase` | `{ idToken }` |
| GET | `/auth/me` | auth |
| PATCH | `/auth/me` | `{ name?, phone?, language?, theme?, avatar?, fcmToken? }` |
| POST | `/auth/logout` | auth |

## Public catalog

| Method | Path | Notes |
|---|---|---|
| GET | `/app/config` | banners, onboarding, settings |
| GET | `/app/version?platform=ios\|android` | force upgrade |
| GET | `/categories` | tree |
| GET | `/categories/:id` | |
| GET | `/products` | query: categoryId, search, featured, newArrival, bestSeller, gender, page, limit, sort |
| GET | `/products/:id` | |
| GET | `/custom-fields?categoryId=` | fields for custom orders |

## Customer (auth, guest blocked)

| Method | Path |
|---|---|
| GET/POST/PATCH/DELETE | `/favorites`, `/favorites/:productId` |
| GET | `/cart` |
| POST | `/cart/items` `{ productId, variant?, quantity, size? }` |
| PATCH | `/cart/items/:itemId` `{ quantity }` |
| DELETE | `/cart/items/:itemId` |
| DELETE | `/cart` |
| POST | `/orders` `{ address, notes?, paymentMethod: "COD" }` |
| GET | `/orders` |
| GET | `/orders/:id` |
| POST | `/orders/:id/cancel` |
| POST | `/custom-orders` multipart + JSON fields |
| GET | `/custom-orders` |
| GET | `/custom-orders/:id` |
| POST | `/custom-orders/:id/confirm` `{ proposalId }` |
| POST | `/custom-orders/:id/reject` `{ proposalId, reason }` |
| GET | `/custom-orders/:id/messages` |
| POST | `/custom-orders/:id/messages` `{ text?, type }` + files |
| GET | `/notifications` |
| PATCH | `/notifications/:id/read` |
| POST | `/uploads` | multipart `file` |

Order statuses: `pending`, `accepted`, `rejected`, `preparing`, `ready`, `out_for_delivery`, `delivered`, `completed`, `cancelled`

Custom order statuses: `draft`, `submitted`, `under_review`, `need_more_details`, `quote_sent`, `waiting_confirmation`, `confirmed`, `rejected`, `in_preparation`, `ready_shipped`, `completed`, `cancelled`

Payment method: `COD` \| `ONLINE`  
Payment status: `pending`, `paid`, `failed`, `refunded`, `cancelled`

## Admin (`/admin/*`, staff only)

| Method | Path |
|---|---|
| GET | `/admin/dashboard` |
| CRUD | `/admin/products` |
| CRUD | `/admin/categories` |
| CRUD | `/admin/custom-fields` |
| GET/PATCH | `/admin/orders`, `/admin/orders/:id`, `/admin/orders/:id/status` |
| GET/PATCH | `/admin/custom-orders` |
| POST | `/admin/custom-orders/:id/proposals` |
| GET | `/admin/customers` |
| PATCH | `/admin/customers/:id` `{ status: active\|blocked }` |
| GET | `/admin/chats` |
| GET/POST | `/admin/chats/:id/messages` |
| POST | `/admin/notifications` `{ title, body, target: all\|userIds, userIds? }` |
| GET/PATCH | `/admin/app-config` |
| GET | `/admin/reports?from&to` |
| GET | `/admin/audit-logs` |
| GET | `/admin/roles` |
| PATCH | `/admin/roles/:id` |

Status change body: `{ status, rejectionReason? }` — rejectionReason required when rejected.

## Seed admin

`admin@placemarket.com` / `Admin@123456` (super_admin)
