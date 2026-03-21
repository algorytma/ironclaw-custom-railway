# IronClaw on Railway

Railway-ready wrapper for deploying [IronClaw](https://github.com/nearai/ironclaw) with PostgreSQL and pgvector.

## What this repo does

The upstream IronClaw project is not directly optimized for Railway public networking in its default form. This wrapper makes it easier to deploy IronClaw on Railway by adding a small public-facing proxy layer and a simple container entrypoint suitable for Railway.

This setup is designed to work with:

- IronClaw app service
- PostgreSQL service with pgvector
- Railway private networking
- Railway public HTTP domain for the app

## Included files

- `Dockerfile` — builds IronClaw and packages the Railway-ready runtime
- `Caddyfile` — exposes Railway's public port and proxies traffic to IronClaw
- `docker-entrypoint.sh` — starts IronClaw and the proxy inside the container

## Services required in Railway

This deployment uses 2 services:

1. **ironclaw** — this repo
2. **Postgres** — Docker image using pgvector

Recommended Postgres image:

```text
pgvector/pgvector:pg16-trixie
