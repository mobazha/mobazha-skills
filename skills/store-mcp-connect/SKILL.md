# Connect AI Agent to Your Store (MCP)

Connect your AI coding agent to your Mobazha store via MCP (Model Context Protocol). Once connected, your agent can directly manage products, orders, messages, and more — no manual API calls needed.

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

## Prerequisites

1. A running Mobazha store (standalone or SaaS)
2. Admin credentials (password for standalone, or API token)
3. The `mobazha-mcp` binary installed (for stdio mode)

### Install the MCP Binary

For standalone stores, `mobazha-mcp` is built from the same codebase:

```bash
cd ~/go/src/github.com/mobazha/mobazha3.0
go build -o mobazha-mcp ./mcp/cmd/mobazha-mcp/
sudo mv mobazha-mcp /usr/local/bin/
```

Or download the pre-built binary from GitHub Releases (when available).

## Connection Modes

### Mode 1: stdio (Local — Recommended)

The AI agent launches `mobazha-mcp` as a subprocess. Best for local stores or when SSH-tunneling to a remote store.

```bash
mobazha-mcp \
  --gateway-url http://localhost:8100 \
  --token <your-admin-token>
```

| Flag | Default | Description |
|------|---------|-------------|
| `--gateway-url` | `http://localhost:8100` | Store gateway URL |
| `--token` | (required) | Admin auth token |
| `--search-url` | (optional) | Marketplace search API URL |

Environment variables: `MOBAZHA_TOKEN`, `MOBAZHA_GATEWAY_URL`, `MOBAZHA_SEARCH_URL`.

### Mode 2: SSE (Remote — Built into Gateway)

The store gateway exposes an MCP SSE endpoint. No binary installation needed — the AI agent connects directly over HTTP.

```
SSE endpoint: https://shop.example.com/platform/v1/mcp
```

Each tool call carries the auth token in the request header.

## Platform Configuration

### Claude Desktop / Claude Code

Add to `~/.claude/claude_desktop_config.json` (or the project `.mcp.json`):

```json
{
  "mcpServers": {
    "mobazha-store": {
      "command": "mobazha-mcp",
      "args": [
        "--gateway-url", "http://localhost:8100",
        "--token", "<your-admin-token>"
      ]
    }
  }
}
```

For remote stores, use SSH tunnel first:
```bash
ssh -L 8100:localhost:8100 root@<vps-ip>
```

Then configure with `http://localhost:8100` as the gateway URL.

### Cursor

Go to **Settings -> MCP Servers -> Add Server**:

- **Name**: `mobazha-store`
- **Type**: `command`
- **Command**: `mobazha-mcp`
- **Args**: `--gateway-url http://localhost:8100 --token <your-admin-token>`

Or add to `.cursor/mcp.json` in your project:

```json
{
  "mcpServers": {
    "mobazha-store": {
      "command": "mobazha-mcp",
      "args": [
        "--gateway-url", "http://localhost:8100",
        "--token", "<your-admin-token>"
      ]
    }
  }
}
```

### Codex CLI

```bash
codex mcp add mobazha-store -- mobazha-mcp \
  --gateway-url http://localhost:8100 \
  --token <your-admin-token>
```

### OpenCode

Add to `opencode.json`:

```json
{
  "mcp": {
    "mobazha-store": {
      "command": "mobazha-mcp",
      "args": [
        "--gateway-url", "http://localhost:8100",
        "--token", "<your-admin-token>"
      ]
    }
  }
}
```

### Using SSE (Any Platform)

For platforms that support SSE MCP connections, use the store's built-in endpoint:

```
URL: https://shop.example.com/platform/v1/mcp
Headers:
  Authorization: Bearer <your-admin-token>
```

No binary installation required.

## Getting Your Auth Token

### Standalone Stores (Basic Auth)

For standalone stores, authentication uses HTTP Basic Auth. The "token" for MCP is the base64-encoded `admin:<password>` string:

```bash
echo -n "admin:your-password" | base64
```

Use the resulting string as the `--token` value. The MCP bridge handles Basic Auth translation.

### SaaS Stores (API Token)

For SaaS stores, generate an API token from the admin dashboard:

1. Go to **Admin -> Settings -> API**
2. Click **Generate Token**
3. Copy the token and use it as `--token`

## Verify the Connection

After configuring, ask your AI agent:

> "List my store's products" or "Show my recent orders"

The agent should call `listings_list_mine` or `orders_get_sales` and return results. If it works, the connection is live.

## Troubleshooting

### "connection refused" or "dial tcp" errors
- Verify the store is running: `curl http://localhost:8100/healthz`
- For remote stores, ensure the SSH tunnel is active
- Check that the gateway port matches (`8100` is the default)

### "401 Unauthorized"
- Verify the token is correct
- For standalone: ensure the token is the base64 of `admin:<password>`
- For SaaS: ensure the API token has not expired

### "tool not found"
- The `search_listings` and `search_profiles` tools only appear when `--search-url` is configured
- Other tools require appropriate scopes on the API token

## Credential Handling

- Store the token in environment variables (`MOBAZHA_TOKEN`), not in config files committed to git
- Add `*.json` containing MCP configs to `.gitignore` if they contain tokens
- Tokens for standalone stores are derived from the admin password — if the password changes, regenerate the token
