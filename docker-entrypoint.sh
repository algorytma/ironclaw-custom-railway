#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${HOME}/.ironclaw"

cat > "${HOME}/.ironclaw/.env" <<EOF
DATABASE_URL=${DATABASE_URL:-}
LLM_BACKEND=${LLM_BACKEND:-openai}
OPENAI_API_KEY=${OPENAI_API_KEY:-}
SECRETS_MASTER_KEY=${SECRETS_MASTER_KEY:-}
SANDBOX_ENABLED=${SANDBOX_ENABLED:-false}
HTTP_HOST=${HTTP_HOST:-0.0.0.0}
HTTP_PORT=${HTTP_PORT:-8080}
GATEWAY_AUTH_TOKEN=${GATEWAY_AUTH_TOKEN:-}
EOF

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
