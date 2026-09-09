# Backend deployment

## Environment

Copy `backend/.env.example` to `.env` on the server. Required:

- `MONGODB_URI`
- `JWT_SECRET` (long random string)
- `CORS_ORIGINS` (admin + any web origins)
- `NODE_ENV=production`
- `PORT` (default 3000)

Never commit `.env` or Firebase private keys.

## Build & start

```bash
cd backend
npm ci
npm run build
NODE_ENV=production node dist/main
```

Process manager example (PM2):

```bash
pm2 start dist/main.js --name placemarket-api
```

## Database

MongoDB 7+. For Compose-based hosts the repo `docker-compose.yml` runs Mongo on port 27017. Take regular dumps:

```bash
mongodump --uri="$MONGODB_URI" --out=/backups/placemarket
```

## HTTPS / reverse proxy

Terminate TLS on nginx/Caddy and proxy to `127.0.0.1:3000`.

```
location / {
  proxy_pass http://127.0.0.1:3000;
  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

Health check: `GET /api/v1/health`

Swagger: `GET /docs` (disable or protect in production if desired).

## Uploads

Local disk `UPLOAD_DIR` is fine for development. For production, point the uploads module at Firebase Storage or S3 and serve via HTTPS.

## Environments

Use separate MongoDB databases and Firebase projects for development, staging, and production. CI can run `npm run build` and lint on every push.
