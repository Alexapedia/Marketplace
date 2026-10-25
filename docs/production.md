# Production

Everything runs from `deploy/` with Docker Compose: MongoDB, the API, the website, the admin, the holder (platform only) and one nginx front proxy that sends each host to its container.

Two ways to run it:

| | Platform (you, many stores) | Single store (a buyer) |
|---|---|---|
| Start | `./scripts/compose.sh --profile platform up -d --build` | `./scripts/compose.sh up -d --build` |
| Holder | yes | no |
| `API_HOSTS` | your API host | empty (every host serves the one store) |

All commands below run in `deploy/`.

## 1. Server

- A VPS with Docker and the compose plugin (2 vCPU, 4 GB RAM to start).
- **Firewall:** allow 80 and 443 only from Cloudflare's ranges (listed in `proxy/cloudflare-realip.conf`), and SSH only from your IP. Use the provider's cloud firewall (Hetzner Firewalls, DigitalOcean Cloud Firewalls): Docker publishes ports past `ufw`, so `ufw` alone does not protect them.

## 2. Cloudflare

1. DNS records, proxied (orange cloud), pointing at the server IP: `api`, `holder`, and `*`.
2. SSL/TLS mode: **Full (strict)**.
3. SSL/TLS → Origin Server → Create certificate for `yourplatform.com` and `*.yourplatform.com`. Save the certificate as `deploy/certs/origin.pem` and the key as `deploy/certs/origin.key`. Note the expiry date.

Store hosts: `<slug>.yourplatform.com` (website) and `<slug>-admin.yourplatform.com` (admin). The free certificate covers one subdomain level only, hence `slug-admin`, not `admin.slug`.

## 3. Settings

```bash
cp .env.example .env
```

Fill in every value. Generate secrets with `openssl rand -hex 32`. Keep the Mongo password to letters and digits. `.env` and `certs/` are ignored by git; keep a copy somewhere safe.

## 4. Start

```bash
./scripts/compose.sh --profile platform up -d --build
./scripts/compose.sh ps
curl -fsS https://api.yourplatform.com/api/v1/health
```

On an empty database the API creates the default store, its roles, the first admin (`SEED_ADMIN_*`) and the holder owner (`SEED_HOLDER_*`). No demo products are added in production.

**Moving existing data instead:** dump your current database and restore it into the new one (see Backups), then copy your `uploads` folder in.

Then in the holder set each store's hosts, for example Zezo: `zezo.yourplatform.com` and `zezo-admin.yourplatform.com`.

## 5. Backups

```bash
./scripts/backup.sh                     # database + uploaded images into backups/
./scripts/restore.sh <stamp> --yes      # replaces current data with that backup
```

Run daily with cron: `0 3 * * * /path/to/deploy/scripts/backup.sh`. For an off-site copy, configure rclone for Cloudflare R2 and set `BACKUP_RCLONE_REMOTE` (for example `r2:placemarket-backups`). Restore one backup on a test machine before going live.

## 6. Updating

```bash
git pull
./scripts/compose.sh --profile platform up -d --build
```

Client frontends with their own branch are rebuilt by `./scripts/deploy-client.sh` (see `docs/clients.md`).

When Cloudflare changes its IP ranges: `./scripts/update-cloudflare-ips.sh`, then `./scripts/compose.sh exec proxy nginx -s reload`, and update the cloud firewall.

## Single store for a buyer

The buyer's own server, their own Cloudflare zone and certificate, their branch (`client/<slug>`) delivered as their repo.

1. In `.env`: `DEFAULT_TENANT_SLUG=<their slug>`, `API_HOSTS=` (empty), `API_HOST=api.<their domain>`.
2. `./scripts/compose.sh up -d --build` (no holder).
3. Set their store's name, logo and colours once: start the holder for the setup only, `HOLDER_HOST=holder.<their domain>` and `./scripts/compose.sh --profile platform up -d holder`, edit the store, then `./scripts/compose.sh stop holder`.

## How requests flow

- Cloudflare → `proxy` (TLS with the origin certificate) → the container for that host (`proxy/templates/default.conf.template`). The original `Host` is kept: the API picks the store from it.
- The proxy restores the visitor's IP from `CF-Connecting-IP` only for requests from Cloudflare's ranges and passes it on, so rate limits apply per visitor.
- MongoDB and the API are not published; only the proxy listens on 80/443.
- Uploaded images live in the `uploads` volume and the database in `mongo_data`; both survive rebuilds.
