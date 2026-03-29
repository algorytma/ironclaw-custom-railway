#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${HOME}/.ironclaw"

cat > "${HOME}/.ironclaw/.env" <<EOF
DATABASE_URL=${DATABASE_URL:-}
LLM_BACKEND=${LLM_BACKEND:-openai}
OPENAI_API_KEY=${OPENAI_API_KEY:-}
OPENAI_API_BASE=${OPENAI_API_BASE:-https://api.openai.com/v1}
OPENAI_MODEL_ID=${OPENAI_MODEL_ID:-minimaxai/minimax-m2.5}
LLM_FAILOVER_BACKEND=${LLM_FAILOVER_BACKEND:-}
LLM_FAILOVER_API_KEY=${LLM_FAILOVER_API_KEY:-}
SMART_ROUTING_ENABLED=${SMART_ROUTING_ENABLED:-false}
SECRETS_MASTER_KEY=${SECRETS_MASTER_KEY:-}
SANDBOX_ENABLED=${SANDBOX_ENABLED:-false}
ONBOARD_COMPLETED=${ONBOARD_COMPLETED:-true}
HTTP_HOST=${HTTP_HOST:-0.0.0.0}
HTTP_PORT=${HTTP_PORT:-8081}
HTTP_WEBHOOK_SECRET=${HTTP_WEBHOOK_SECRET:-}
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
