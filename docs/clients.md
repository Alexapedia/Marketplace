# Client branches

Each client gets a branch `client/<slug>` cut from `main`, for changes that are theirs alone.

```
main                 the product: backend, shared fixes and features
├── client/<buyer>   a buyer's copy (delivered as their repo)
└── client/<store>   a subscriber's own website / admin / app changes
```

## Rules

1. **Client branches change the UI only**: `web/`, `admin/`, `mobile/`. Never `backend/`.
2. **Backend changes go to `main`.** Every subscriber runs on the same API, so it must stay the same for all of them.
3. **Updates flow one way, `main` → client branch,** by merge (never rebase or force-push):

```bash
git checkout client/<slug>
git merge main
```

Subscribers always get updates. Buyers get them only with a maintenance contract.

Colours, logo, favicon, splash and store name come from the holder for subscribers; no branch is needed for those.

## New client

```bash
git checkout main && git pull
git checkout -b client/<slug>
# UI changes, commit
git push -u origin client/<slug>
```

## Subscriber with their own website or admin

On the platform server, in `deploy/`:

```bash
./scripts/deploy-client.sh <slug> <slug>.yourplatform.com <slug>-admin.yourplatform.com shop.theirdomain.com
```

This builds the website and admin from `client/<slug>` (in a git worktree under `deploy/.worktrees/`), starts them as `web-<slug>` and `admin-<slug>`, and sends those hosts to them. Every other store keeps the shared website and admin. Use the same hosts as the store's domains in the holder.

Run the same command again after merging into the branch to redeploy. Always use `./scripts/compose.sh` (not plain `docker compose`) so client frontends stay part of the stack.

## Subscriber or buyer mobile app

Build from their branch with their flavor (see `docs/new-store.md`):

```bash
git checkout client/<slug>
cd mobile && flutter build appbundle --release --flavor <slug> --dart-define=TENANT_SLUG=<slug> ...
```

## Buyer delivery

1. Push their branch to a repo they own: `git push <their-remote> client/<slug>:main`.
2. Deploy on their server as a single store (`docs/production.md`).
3. Later fixes, under a maintenance contract: merge `main` into `client/<slug>` and push to their repo again.
