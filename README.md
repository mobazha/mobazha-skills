# Mobazha Skills

[![Quality Check](https://github.com/mobazha/mobazha-skills/actions/workflows/check.yml/badge.svg)](https://github.com/mobazha/mobazha-skills/actions/workflows/check.yml)

AI-powered skills for [Mobazha](https://mobazha.org) — the decentralized commerce platform. Deploy stores, complete onboarding, import products, and manage your business through AI agents with built-in MCP integration.

## What's Inside

### Deploy and Install

| Skill | Description |
|-------|-------------|
| **standalone-setup** | Deploy a self-hosted Mobazha store on any VPS with Docker |
| **native-install** | Install the native binary on Linux, macOS, or Windows |
| **store-onboarding** | First-time setup: admin password, store profile, region/currency |

### Configure and Connect

| Skill | Description |
|-------|-------------|
| **subdomain-bot-config** | Set up a custom domain and Telegram Bot for your store |
| **tor-browsing** | Configure Tor Browser to access .onion stores privately |
| **store-mcp-connect** | Connect your AI agent to your store via MCP for direct management |

### Operate and Grow

| Skill | Description |
|-------|-------------|
| **store-management** | Manage products, orders, chat, discounts via 30+ MCP tools |
| **product-import** | Bulk import products from Shopify, Amazon, or Etsy — CSV, API, or JSON |
| **competitor-analysis** | Research competitor products, reviews, and pricing to inform your strategy |

### Content and Marketing

| Skill | Description |
|-------|-------------|
| **product-description** | Generate SEO-optimized, conversion-focused product descriptions |
| **store-copywriting** | Write compelling store profile, About section, and campaign copy |
| **storefront-cro** | Audit your storefront and get prioritized conversion optimization tips |
| **product-image-prompt** | Craft AI image generation prompts for product photos and store branding |

## Store Modes

Skills cover three deployment modes:

| Mode | Best For | Getting Started |
|------|----------|----------------|
| **SaaS** | Quick start, no server | Sign up at `app.mobazha.org` |
| **VPS Standalone** | Full control, custom domain | Follow `standalone-setup` skill |
| **NAT / Local** | Personal use, development | Follow `native-install` skill |

## MCP Integration

This plugin includes an MCP server configuration for `mobazha-mcp` — a Model Context Protocol server that gives your AI agent direct access to your store's API.

Once connected, your agent can:

- Create, update, and delete products
- View and process orders (confirm, fulfill, refund)
- Send messages to buyers
- Manage discounts and collections
- Check notifications and exchange rates

See the **store-mcp-connect** skill for setup instructions.

## Installation

### Claude Code (Official Marketplace)

```
/plugin install mobazha@claude-plugins-official
```

### Claude Code (Mobazha Marketplace)

```
/plugin marketplace add mobazha/mobazha-skills
/plugin install mobazha@mobazha
```

### Cursor

```
/add-plugin mobazha
```

### OpenAI Codex CLI

```
codex marketplace add mobazha/mobazha-skills
```

### GitHub Copilot CLI

```
copilot plugin marketplace add mobazha/mobazha-skills
```

### OpenCode

Add to your `opencode.json`:

```json
{
  "plugin": ["mobazha@git+https://github.com/mobazha/mobazha-skills.git"]
}
```

### Gemini CLI

```
gemini extensions install https://github.com/mobazha/mobazha-skills
```

### OpenClaw

```
openclaw plugins install mobazha
```

## How It Works

Once installed, your AI agent automatically discovers Mobazha skills. Ask it things like:

- "Help me deploy a Mobazha store on my VPS"
- "Walk me through the store setup wizard"
- "Connect to my store and list my products"
- "Import my Shopify products into Mobazha"
- "Check my recent orders and fulfill the pending ones"
- "Set up a custom domain and Telegram bot for my store"
- "Write a better description for my handmade leather wallets"
- "Audit my store and tell me how to get more sales"
- "Generate product photo prompts for my candle collection"
- "Analyze the competition on Etsy for organic skincare"

The agent loads the relevant skill and walks you through the process step by step.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding or improving skills.

See [TESTING.md](TESTING.md) for how to verify skills against a real store.

## About Mobazha

[Mobazha](https://mobazha.org) is a decentralized commerce platform for independent sellers. Zero commissions, built-in escrow protection, crypto + fiat payments, and full data sovereignty.

- **Website**: <https://mobazha.org>
- **Self-Host Guide**: <https://mobazha.org/self-host>
- **Telegram**: <https://t.me/MobazhaHQ>
- **GitHub**: <https://github.com/mobazha>

## License

MIT License — see [LICENSE](LICENSE) for details.
