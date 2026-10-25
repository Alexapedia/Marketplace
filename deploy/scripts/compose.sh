#!/usr/bin/env sh
# docker compose for this stack, always including every client's frontends
# (clients/*.yml), so no client is left out of an up/down/restart.
#   ./scripts/compose.sh --profile platform up -d --build
set -eu
cd "$(dirname "$0")/.."
# The main file comes first and the project directory is this folder, so
# .env and relative build paths resolve here, not under clients/.
files="-f docker-compose.prod.yml"
for f in clients/*.yml; do
  [ -e "$f" ] && files="$files -f $f"
done
# shellcheck disable=SC2086 # file paths have no spaces
exec docker compose --project-directory . $files "$@"
