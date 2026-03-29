# Deploy and Host Custom IronClaw on Railway

IronClaw is a secure AI assistant with a modern web interface, persistent memory, jobs, routines, and tool-based workflows. It combines chat, automation, and long-term state in one system. 

This customized wrapper builds upon the fantastic upstream project by **nearai** and seamlessly upgrades the engine to natively support external LLM providers like **Nvidia NIM**, alongside automated failover capabilities to **OpenRouter**. We are incredibly grateful for nearai's brilliant foundation that made these workflow improvements possible.

---

## About Hosting IronClaw

Hosting IronClaw involves running the main application service together with a PostgreSQL database that supports pgvector for persistence and memory-related features. 

We have taken the base functionality from the original repository and humbly enhanced the Railway integration. This specific template ensures that:

- It runs behind a public HTTP wrapper with non-interactive startup.
- The IronClaw web node is fully stateless, safely relying entirely on the PostgreSQL volume.
- Secure keys, database URLs, and authentication tokens are automatically populated via Railway variables upon deployment.
- Out-of-the-box compatibility with Nvidia NIM endpoints is mapped perfectly without manual adjustments to the core code.

## Common Use Cases

- **Personal AI assistant** with persistent memory and chat history powered by lightning-fast inference models.
- **Hosted AI workspace** for jobs, routines, and automation flows.
- **Reliable demo or evaluation environment** mapped natively to OpenAI-equivalent APIs.

## Dependencies for IronClaw Hosting

- **PostgreSQL with pgvector** (Automatically provisioned in this template)
- Harmless overrides for mapping Nvidia NIM or any OpenAI-compatible custom LLM backend.

### Deployment Dependencies

- **Original Upstream Project**: [nearai/ironclaw](https://github.com/nearai/ironclaw) *(A massive thank you to the nearai team for the brilliant core framework!)*
- **pgvector Docker image**: [pgvector/pgvector](https://hub.docker.com/r/pgvector/pgvector)
- **Railway platform**: [Railway.app](https://railway.com/)

## Implementation Details

This template deploys IronClaw using two perfectly harmonized services:

1. **IronClaw** application service (Configured with automated port handling and dynamic entrypoints)
2. **PostgreSQL** database service with pgvector (Isolated in an internal private network)

### Recommended Environment Setup for the IronClaw Service (Pre-configured):
```env
DATABASE_URL=postgresql://${{Postgres.POSTGRES_USER}}:${{Postgres.POSTGRES_PASSWORD}}@Postgres.railway.internal:5432/${{Postgres.POSTGRES_DB}}?sslmode=disable
LLM_BACKEND=openai
OPENAI_API_BASE=https://integrate.api.nvidia.com/v1
OPENAI_MODEL_ID=minimaxai/minimax-m2.5
OPENAI_API_KEY=${{ secret() }}
LLM_FAILOVER_BACKEND=openai
LLM_FAILOVER_API_KEY=${{ secret() }}
GATEWAY_AUTH_TOKEN=${{ secret(32) }}
SECRETS_MASTER_KEY=${{ secret(64) }}
HTTP_WEBHOOK_SECRET=${{ secret(32) }}
ONBOARD_COMPLETED=true
SANDBOX_ENABLED=false
PORT=8080
HTTP_HOST=0.0.0.0
HTTP_PORT=8081
```

> **Note:** Replace `OPENAI_API_KEY` with your Nvidia NIM key, and `LLM_FAILOVER_API_KEY` with your OpenRouter key during deployment.

### Recommended Environment Setup for the Postgres Service (Pre-configured):
```env
POSTGRES_DB=ironclaw
POSTGRES_USER=ironclaw
POSTGRES_PASSWORD=${{ secret(32) }}
PGDATA=/var/lib/postgresql/data/pgdata
```

## Gateway Login Token

IronClaw’s web interface is explicitly protected by a gateway login token.

In this customized template, we have securely automated the generation of the `GATEWAY_AUTH_TOKEN` string utilizing Railway's secret generation. Upon successful deployment, navigate to your IronClaw service's "Variables" tab to retrieve your securely generated **32-character authentication token** so you can log into your personal UI instance.

## Why Deploy IronClaw on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it. By deploying this upgraded IronClaw template on Railway, you are one step closer to supporting a complete full-stack application with absolutely minimal technical burden.
