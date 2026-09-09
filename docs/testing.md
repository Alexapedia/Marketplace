# Testing

## API

1. `docker compose up -d mongo`
2. `cd backend && npm run start:dev`
3. Open http://localhost:3000/docs
4. Health: `curl http://localhost:3000/api/v1/health`
5. Login:

```bash
curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@placemarket.com","password":"Admin@123456"}'
```

Suggested manual cases:

- Guest product browse (`GET /products`)
- Register customer, add to cart, COD checkout (totals from server)
- Reject an order from admin with a reason; confirm it appears on the order
- Custom request + proposal + confirm (creates a standard order)
- Force-upgrade: set Android minimum above the app version and confirm the mobile upgrade screen

## Admin

`cd admin && npm start` → http://localhost:4200  
Sign in with the seed admin. Walk Dashboard, Products, Orders, Custom Orders, App config.

## Mobile

`cd mobile && flutter run`  
Guest home → login → cart → custom order. Switch Arabic and dark mode from Profile.

`flutter analyze` should be clean.

Automated unit/e2e suites are not the first-release gate; add Jest e2e and widget tests as Phase 8 hardens.
