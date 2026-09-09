# Architecture

```
Flutter app  ──┐
               ├──  HTTPS ──►  NestJS /api/v1  ──► MongoDB
Angular admin ─┘                    │
                                    ├── JWT (email/password)
                                    ├── Firebase Admin (optional ID tokens + FCM)
                                    └── local /uploads (swap for Firebase Storage later)
```

## Backend modules

| Module | Responsibility |
|---|---|
| Auth | Register, login, Firebase sync, profile, password reset |
| Catalog | Categories, products, custom fields |
| Favorites / Cart | Signed-in only; prices snapshotted from DB |
| Orders | COD checkout, server-side totals, status workflow |
| Custom orders | Structured fields, attachments, proposals, confirm/reject |
| Chat | Conversation per custom request |
| Notifications | In-app records + FCM stub |
| App config | Banners, onboarding, force-upgrade versions |
| Admin | Dashboard, CRUD, reports, audit, roles |
| Uploads | Image/PDF to disk |
| Payments | `PaymentProvider` interface; COD implementation now |
| Seed | Roles, admin, sample catalog |

## Security rules

- Firebase or JWT tokens are validated on the server.
- Client-sent prices and totals are ignored at checkout.
- Staff APIs require staff roles and permission strings.
- Auth routes are rate-limited via `@nestjs/throttler`.
- Rejection always stores a reason.

## Localization & theme

Mobile and admin both support English/Arabic (RTL) and light/dark. Product and category names are `{ en, ar }` objects.
