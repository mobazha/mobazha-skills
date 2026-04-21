# Connect AI Agent to Your Store (MCP)

Connect your AI coding agent to your Mobazha store via MCP (Model Context Protocol). Once connected, your agent can directly manage products, orders, messages, and more.

## What You Get

After connecting, your AI agent has access to 30+ store management tools:

| Category | Tools | What They Do |
|----------|-------|-------------|
| **Products** | `listings_create`, `listings_update`, `listings_delete`, `listings_list_mine` | Full product CRUD |
| **Orders** | `orders_get_sales`, `orders_confirm`, `orders_fulfill`, `orders_refund` | Order lifecycle |
| **Chat** | `chat_get_conversations`, `chat_send_message` | Buyer communication |
| **Discounts** | `discounts_create`, `discounts_update`, `discounts_delete` | Promotions |
| **Collections** | `collections_create`, `collections_add_products` | Product organization |
| **Profile** | `profile_get`, `profile_update` | Store identity |
| **Notifications** | `notifications_list`, `notifications_mark_read` | Activity feed |
| **Search** | `search_listings`, `search_profiles` | Marketplace discovery |
| **Finance** | `exchange_rates_get`, `wallet_get_receiving_accounts`, `fiat_get_providers` | Payments and rates |

## Choose Your Scenario

| Scenario | Transport | Connection Target |
|----------|-----------|-------------------|
| **Local store** (native or Docker) | stdio | `localhost:8100` (native) or `localhost` (Docker) |
| **Remote VPS** | stdio via SSH tunnel (recommended) or SSE | SSH to VPS, then `localhost:8100` |
| **SaaS platform** | SSE | `https://app.mobazha.org/platform/v1/mcp` |

---

## Scenario A: Local Store (Native or Docker)

Your store runs on the same machine as your AI agent. This is the simplest setup.

### Prerequisites

1. A running Mobazha store (onboarding completed — see `store-onboarding` skill)
2. The `mobazha-mcp` binary installed

### Install the MCP Binary

Download from GitHub Releases (when available), or build from source:

```bash
go install github.com/mobazha/mobazha3.0/mcp/cmd/mobazha-mcp@latest
```

### Get Your Bearer Token

Obtain an API token for MCP authentication:

```bash
curl -X POST http://localhost:8100/platform/v1/auth/tokens \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "<your-admin-password>"}'
```

Save the returned token. Set it as an environment variable:

```bash
export MOBAZHA_TOKEN="<your-token>"
```

### Configure Your AI Agent

**Claude Desktop / Claude Code** — add to `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "mobazha-store": {
      "command": "mobazha-mcp",
      "args": ["--gateway-url", "http://localhost:8100"]
    }
  }
}
```

**Cursor** — add to `.cursor/mcp.json` in your project:

```json
{
  "mcpServers": {
    "mobazha-store": {
      "command": "mobazha-mcp",
      "args": ["--gateway-url", "http://localhost:8100"]
    }
  }
}
```

Or go to **Settings > MCP Servers > Add Server** and enter the command manually.

**Codex CLI**:

```bash
codex mcp add mobazha-store -- mobazha-mcp --gateway-url http://localhost:8100
```

**OpenCode** — add to `opencode.json`:

```json
{
  "mcp": {
    "mobazha-store": {
      "command": "mobazha-mcp",
      "args": ["--gateway-url", "http://localhost:8100"]
    }
  }
}
```

The `MOBAZHA_TOKEN` environment variable is automatically picked up by `mobazha-mcp`. Alternatively, pass `--token <token>` as a CLI flag.

---

## Scenario B: Remote VPS

Your store runs on a remote server. Two options: SSH tunnel (recommended) or direct SSE.

### Option 1: SSH Tunnel + stdio (Recommended)

This is the most secure approach — no need to expose the MCP endpoint publicly.

**Step 1**: Open an SSH tunnel to your VPS:

```bash
ssh -L 8100:localhost:8100 root@<vps-ip>
```

This maps your local port 8100 to the store's gateway on the VPS.

**Step 2**: Get a Bearer token (through the tunnel):

```bash
curl -X POST http://localhost:8100/platform/v1/auth/tokens \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "<your-admin-password>"}'
```

**Step 3**: Configure your AI agent with the same local configs as Scenario A (pointing to `http://localhost:8100`).

### Option 2: SSE (Direct Remote Connection)

If your store has a public domain with HTTPS, your AI agent can connect directly via SSE without installing `mobazha-mcp`.

```
SSE endpoint: https://shop.example.com/platform/v1/mcp
```

For platforms that support SSE MCP connections, use:

- **URL**: `https://shop.example.com/platform/v1/mcp`
- **Header**: `Authorization: Bearer <your-token>`

Get the token the same way as above (via `/platform/v1/auth/tokens`).

---

## Scenario C: SaaS Platform

Your store is hosted on `app.mobazha.org`. Connect via SSE.

### Get an API Token

1. Log in to your store at `app.mobazha.org`
2. Go to **Settings > API**
3. Click **Generate Token**
4. Copy the token

### Connect via SSE

The SaaS platform exposes the MCP endpoint at:

```
https://app.mobazha.org/platform/v1/mcp
```

For AI agent platforms that support SSE MCP connections, configure:

- **URL**: `https://app.mobazha.org/platform/v1/mcp`
- **Header**: `Authorization: Bearer <your-api-token>`

### Connect via stdio (with mobazha-mcp)

You can also use the `mobazha-mcp` binary pointing to the SaaS gateway:

```bash
mobazha-mcp \
  --gateway-url https://app.mobazha.org \
  --token <your-api-token>
```

Configure your AI agent the same way as Scenario A, replacing the gateway URL.

---

## CLI Reference

| Flag | Env Variable | Default | Description |
|------|-------------|---------|-------------|
| `--gateway-url` | `MOBAZHA_GATEWAY_URL` | `http://localhost:8100` | Store gateway URL |
| `--token` | `MOBAZHA_TOKEN` | (required) | Bearer token for authentication |
| `--search-url` | `MOBAZHA_SEARCH_URL` | (optional) | Marketplace search API URL |

## Verify the Connection

After configuring, ask your AI agent:

> "List my store's products" or "Show my recent orders"

The agent should call `listings_list_mine` or `orders_get_sales` and return results. If it works, the connection is live.

For a guide on what you can do with MCP tools, see the `store-management` skill.

## Troubleshooting

### "connection refused" or "dial tcp" errors
- Verify the store is running: `curl http://localhost:8100/healthz`
- For remote stores, ensure the SSH tunnel is active
- Check that the gateway port matches (8100 is the default for native; Docker standalone proxies through port 80/443)

### "401 Unauthorized"
- Verify the token: `curl -H "Authorization: Bearer <token>" http://localhost:8100/v1/profiles`
- Token may have expired — generate a new one via `/platform/v1/auth/tokens`
- For SaaS: ensure the API token is still valid in Settings > API

### "tool not found"
- `search_listings` and `search_profiles` only appear when `--search-url` is configured
- Some tools require specific scopes on the API token

### Credential Safety
- Store the token in environment variables (`MOBAZHA_TOKEN`), not in config files committed to git
- Add MCP config files to `.gitignore` if they contain tokens
- Tokens can be revoked and regenerated at any time
