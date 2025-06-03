#!/bin/sh
set -e

[ -f /usr/share/zoneinfo/$TZ ] && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

exec /usr/local/bin/cloudflared proxy-dns \
  --address="${ADDRESS:-0.0.0.0}" \
  --port="${PORT:-54}" \
  --metrics="${METRICS:-127.0.0.1:8080}" \
  --upstream="https://${DNS1:-1.1.1.3}/dns-query" \
  --upstream="https://${DNS2:-security.cloudflare-dns.com}/dns-query" \
  --upstream="https://1.1.1.2/dns-query" \
  --max-upstream-conns="${MAX_UPSTREAM_CONNS:-0}"