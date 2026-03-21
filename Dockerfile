FROM rust:1.92-slim-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libssl-dev cmake gcc g++ git \
    && rm -rf /var/lib/apt/lists/* \
    && rustup target add wasm32-wasip2 \
    && cargo install wasm-tools

WORKDIR /build

RUN git clone --depth 1 --branch v0.20.0 https://github.com/nearai/ironclaw.git /build/ironclaw

WORKDIR /build/ironclaw

RUN cargo build --release --bin ironclaw

FROM caddy:2.10.2-builder AS caddy_builder
RUN xcaddy build

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl3 bash curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/ironclaw/target/release/ironclaw /usr/local/bin/ironclaw
COPY --from=builder /build/ironclaw/migrations /app/migrations
COPY --from=caddy_builder /usr/bin/caddy /usr/bin/caddy

COPY Caddyfile /etc/caddy/Caddyfile
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && useradd -m -u 1000 -s /bin/bash ironclaw

USER ironclaw
WORKDIR /home/ironclaw

ENV RUST_LOG=ironclaw=info
ENV SANDBOX_ENABLED=false

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
