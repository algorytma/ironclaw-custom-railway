#!/usr/bin/env bash
set -euo pipefail

if [ -z "${PORT:-}" ]; then
  export PORT=8080
fi

ironclaw &
IRONCLAW_PID=$!

sleep 5

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
CADDY_PID=$!

cleanup() {
  kill "$CADDY_PID" "$IRONCLAW_PID" 2>/dev/null || true
}

trap cleanup SIGINT SIGTERM

wait -n "$IRONCLAW_PID" "$CADDY_PID"
exit $?
