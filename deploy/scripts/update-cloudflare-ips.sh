#!/usr/bin/env sh
# Rewrites proxy/cloudflare-realip.conf from Cloudflare's published ranges.
# Run when Cloudflare announces changes, then: docker compose exec proxy nginx -s reload
set -eu
cd "$(dirname "$0")/.."
out=proxy/cloudflare-realip.conf
tmp=$(mktemp)
{
  echo "# Cloudflare edge ranges (https://www.cloudflare.com/ips/), fetched $(date -u +%Y-%m-%d)."
  echo "# Only requests from these addresses may set the client IP via CF-Connecting-IP."
  for v in v4 v6; do
    curl -fsS "https://www.cloudflare.com/ips-$v" | while read -r range || [ -n "$range" ]; do
      [ -n "$range" ] && echo "set_real_ip_from $range;"
    done
  done
  echo "real_ip_header CF-Connecting-IP;"
} > "$tmp"
mv "$tmp" "$out"
echo "Wrote $out"
