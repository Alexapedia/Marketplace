# PlaceMarket

E-commerce and custom-orders platform from the full product scope:

- **mobile** — Flutter customer app (iOS & Android)
- **admin** — Angular 21 admin dashboard
- **backend** — NestJS REST API (`/api/v1`) with MongoDB
- **website** — customer web store (`web/`, Vite, http://localhost:5173)


Catalog is ready for perfumes, watches, accessories, and clothing. Customers can shop standard products or submit structured custom requests, chat with staff, and confirm admin proposals. Release 1 payment method is Cash on Delivery; online payment is abstracted for later.

## Prerequisites

- Flutter SDK (3.9+)
- Node.js 20+ (LTS recommended)
- Docker (for MongoDB) or a local MongoDB 7 instance

## Quick start

```bash
# 1. Database
docker compose up -d mongo

# 2. API  →  http://localhost:3000/api/v1
#            Swagger: http://localhost:3000/docs
cd backend
cp .env.example .env   # already copied in this workspace
npm run start:dev

# 3. Admin dashboard  →  http://localhost:4200
cd ../admin
npm start

# 4. Customer website  →  http://localhost:5173
cd ../web
npm install
npm run dev

# 5. Mobile app
cd ../mobile
flutter pub get
flutter run
```

### Seed admin

| Email | Password | Role |
|---|---|---|
| `admin@placemarket.com` | `Admin@123456` | super_admin |

Register a customer from the mobile app or `POST /api/v1/auth/register`.

## Projects

| Folder | Stack | Purpose |
|---|---|---|
| `mobile/` | Flutter, Bloc, Dio, go_router, easy_localization | Customer shopping, custom orders, chat, COD |
| `admin/` | Angular 21, Angular Material | Operations: products, orders, proposals, force upgrade |
| `backend/` | NestJS 11, MongoDB, JWT, Swagger | Auth, catalog, cart, orders, custom workflow, FCM-ready |
| `web/` | Vite + TypeScript | Customer storefront (catalog, cart, COD) |

## Docs

- [Customer apps (mobile + website)](docs/customer-apps.md)
- [API contract](docs/API.md)
- [Architecture](docs/architecture.md)
- [Firebase setup](docs/firebase.md)
- [Backend deployment](docs/deployment.md)
- [Mobile store builds](docs/mobile-release.md)
- [Testing](docs/testing.md)
- [Handover checklist](docs/handover.md)

## Local API URL (mobile)

Debug defaults:

- iOS simulator / desktop: `http://127.0.0.1:3000/api/v1`
- Android emulator: `http://10.0.2.2:3000/api/v1`

Override:

```bash
flutter run --dart-define=API_URL=http://192.168.1.10:3000/api/v1
```

Firebase Auth, Google, Apple, and FCM are wired but optional until credentials are supplied. Email/password against the API works without Firebase.

## Branding

Zezo Store uses navy `#071345` and white across mobile, admin, and the customer website.
