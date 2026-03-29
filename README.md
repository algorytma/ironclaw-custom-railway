# ironclaw-railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/ironclaw?referralCode=4pD7Sc&utm_medium=integration&utm_source=template&utm_campaign=generic)

This repository provides a Railway-ready deployment wrapper for IronClaw so it can run correctly in a hosted environment without the common issues that appear when deploying the upstream project directly.

## Overview

IronClaw is a secure AI assistant with chat, memory, jobs, routines, and a web interface. This repository adapts IronClaw for Railway by adding the pieces needed for a smooth hosted deployment.

This setup handles the major problems that usually appear in Railway:

- skipping interactive first-run onboarding
- avoiding localhost-only gateway access
- preventing port conflicts between the gateway and HTTP webhook channel
- running behind a public HTTP wrapper
- using PostgreSQL with pgvector for persistence
- making deployment easier for users who do not want to inspect logs manually

## Deploy

Click the button above, or use this link directly:

https://railway.com/deploy/ironclaw?referralCode=4pD7Sc&utm_medium=integration&utm_source=template&utm_campaign=generic

## What this template includes

This Railway template includes:

- IronClaw application service
- PostgreSQL service with pgvector
- public web access through a wrapper/proxy layer
- non-interactive startup for hosted environments
- persistent PostgreSQL storage
- private internal networking between services

## Why this wrapper exists

The upstream IronClaw project is designed mainly for local or self-managed environments. When deploying to Railway, several things need to be adapted:

- the default onboarding flow is interactive
- the internal gateway runs on localhost
- the public web entrypoint must listen on the Railway service port
- the webhook channel must not conflict with the public proxy port
- hosted users need a cleaner out-of-the-box experience

This repository solves those issues so the app starts correctly on Railway.

## Gateway Token

IronClaw’s web gateway uses a login token to protect access to the browser UI.

This means that after deployment, users may see a token prompt before entering the application. This token is not the same as your OpenAI or other LLM provider API key. It is used only for authenticating access to the IronClaw web interface.

Why this exists:

- protects the hosted UI from unauthorized access
- keeps the internal assistant interface gated behind authentication
- adds a simple security layer for public deployments

In the current Railway deployment flow, the token may be shown by IronClaw at runtime. For a more user-friendly template, the deployment can be extended to generate and inject a stable token automatically so users do not need to search for it manually.

## Architecture

This deployment uses two services.

### 1. ironclaw

The main application service built from this repository.

Responsibilities:

- starts IronClaw with Railway-friendly configuration
- skips interactive onboarding
- proxies public traffic to the internal IronClaw gateway
- keeps the UI accessible from the Railway public domain

### 2. Postgres

A PostgreSQL database service using pgvector.

Responsibilities:

- stores IronClaw data persistently
- supports vector-based features through pgvector
- stays private inside Railway internal networking

Recommended Postgres image:

    pgvector/pgvector:pg16-trixie

## Key Railway-specific changes

This wrapper includes several important deployment changes.

### 1. Non-interactive startup

Interactive first-run onboarding is skipped by preconfiguring the required environment variables for hosted deployment.

### 2. Public wrapper/proxy

IronClaw’s internal gateway runs locally, while the wrapper exposes the public Railway HTTP port and forwards traffic correctly.

### 3. Port separation

The public wrapper and IronClaw HTTP webhook channel run on separate ports to avoid bind conflicts.

Recommended split:

- public wrapper: 8080
- IronClaw webhook channel: 8081
- internal IronClaw gateway: 3000

### 4. Persistent database

Postgres uses a mounted volume so data survives redeploys.

### 5. Railway-friendly networking

- IronClaw is exposed publicly
- Postgres stays private
- internal service communication uses Railway private networking

## Environment variables

### IronClaw service

Use these variables on the IronClaw service:

    DATABASE_URL=postgresql://${{Postgres.POSTGRES_USER}}:${{Postgres.POSTGRES_PASSWORD}}@Postgres.railway.internal:5432/${{Postgres.POSTGRES_DB}}?sslmode=disable
    LLM_BACKEND=openai
    OPENAI_API_KEY=your_openai_api_key
    OPENAI_API_BASE=https://integrate.api.nvidia.com/v1
    OPENAI_MODEL_ID=minimaxai/minimax-m2.5
    LLM_FAILOVER_BACKEND=openai
    LLM_FAILOVER_API_KEY=your_openrouter_api_key
    SMART_ROUTING_ENABLED=true
    ONBOARD_COMPLETED=true
    SANDBOX_ENABLED=false
    PORT=8080
    HTTP_HOST=0.0.0.0
    HTTP_PORT=8081
    HTTP_WEBHOOK_SECRET=${{ secret(32) }}
    GATEWAY_AUTH_TOKEN=${{ secret(32) }}
    SECRETS_MASTER_KEY=${{ secret(32) }}

### Postgres service

Use these variables on the Postgres service:

    POSTGRES_DB=ironclaw
    POSTGRES_USER=ironclaw
    POSTGRES_PASSWORD=${{ secret(16) }}
    PGDATA=/var/lib/postgresql/data/pgdata

## Storage

### Postgres volume

Enable a persistent volume for Postgres.

Recommended mount path:

    /var/lib/postgresql/data

## Networking

### IronClaw service

- public HTTP domain enabled
- public wrapper listens on port 8080

### Postgres service

- no public domain
- private networking only
- persistent volume enabled

## User experience notes

After deployment, the app loads through the Railway public domain and opens the IronClaw UI.

This wrapper was updated to solve:

- first-run onboarding issues
- gateway accessibility problems
- HTTP webhook secret requirement
- port collision between Caddy and IronClaw HTTP channel
- Railway public access routing

## Repository files

This repository includes:

- `Dockerfile` — builds and packages the Railway-ready runtime
- `Caddyfile` — exposes the public Railway port and proxies traffic to IronClaw
- `docker-entrypoint.sh` — starts IronClaw and the public proxy with the required startup behavior
- `README.md` — deployment instructions and template information

## Recommended use cases

This template is a good fit for:

- personal AI assistant hosting
- secure chat and memory workflows
- routine and job automation
- hosted demos of IronClaw
- fast Railway-based evaluation environments

## Important notes

- This repository is a Railway deployment wrapper, not the upstream IronClaw project itself.
- The upstream project remains the source for IronClaw application development.
- This wrapper focuses specifically on reliable Railway deployment behavior.

## Upstream project

Original project:

https://github.com/nearai/ironclaw

## Credits

- Upstream project: nearai/ironclaw
- Railway deployment wrapper: this repository

## Suggested tags

railway, ironclaw, ai-assistant, rust, postgresql, pgvector, self-hosted, automation

## License

Review the upstream IronClaw license before redistributing or publishing derivative deployment wrappers.
