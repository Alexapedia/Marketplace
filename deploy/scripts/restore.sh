#!/usr/bin/env sh
# Restores a backup made by backup.sh. Replaces the current data.
#   ./scripts/restore.sh <stamp> --yes      (stamp as in backups/mongo-<stamp>...)
set -eu
cd "$(dirname "$0")/.."
stamp=${1:-}
[ -n "$stamp" ] && [ "${2:-}" = "--yes" ] || { echo "usage: $0 <stamp> --yes  (this replaces the current database and images)" >&2; exit 2; }
MONGO_USER=$(sed -n 's/^MONGO_USER=//p' .env)
MONGO_PASSWORD=$(sed -n 's/^MONGO_PASSWORD=//p' .env)
./scripts/compose.sh exec -T mongo mongorestore --quiet --drop \
  --username "$MONGO_USER" --password "$MONGO_PASSWORD" --authenticationDatabase admin \
  --archive --gzip < "backups/mongo-$stamp.archive.gz"
./scripts/compose.sh exec -T api tar xzf - -C /app/uploads < "backups/uploads-$stamp.tar.gz"
echo "Restored $stamp"
