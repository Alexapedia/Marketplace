#!/usr/bin/env sh
# Backs up the database and uploaded images into deploy/backups (kept 14 days).
# Off-site copy: set BACKUP_RCLONE_REMOTE in the environment (e.g.
# r2:placemarket-backups) with rclone configured for Cloudflare R2.
# Cron (daily 03:00): 0 3 * * * /path/to/deploy/scripts/backup.sh
set -eu
cd "$(dirname "$0")/.."
MONGO_USER=$(sed -n 's/^MONGO_USER=//p' .env)
MONGO_PASSWORD=$(sed -n 's/^MONGO_PASSWORD=//p' .env)
stamp=$(date -u +%Y%m%d-%H%M%S)
mkdir -p backups
./scripts/compose.sh exec -T mongo mongodump --quiet \
  --username "$MONGO_USER" --password "$MONGO_PASSWORD" --authenticationDatabase admin \
  --archive --gzip > "backups/mongo-$stamp.archive.gz"
./scripts/compose.sh exec -T api tar czf - -C /app/uploads . > "backups/uploads-$stamp.tar.gz"
find backups -type f -mtime +14 -delete
if [ -n "${BACKUP_RCLONE_REMOTE:-}" ]; then
  rclone copy backups "$BACKUP_RCLONE_REMOTE"
fi
echo "Backup done: backups/*-$stamp.*"
