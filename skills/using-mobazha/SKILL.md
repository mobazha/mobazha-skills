---
name: using-mobazha
description: Entry point for Mobazha skills. Provides an overview of available skills and guides the AI agent to load the right one based on user intent.
---

# Using Mobazha Skills

You have access to **Mobazha Skills** — a set of guided workflows for the [Mobazha](https://mobazha.org) decentralized commerce platform.

## What is Mobazha?

Mobazha is a decentralized e-commerce platform for independent sellers. Key features:

- **Zero commissions** — keep 100% of your revenue
- **Self-hosted or SaaS** — deploy on your own server or use the hosted platform
- **Built-in escrow** — trustless buyer protection on every crypto transaction
- **Crypto + fiat payments** — Bitcoin, Litecoin, Zcash, TRON, plus Stripe and PayPal
- **Encrypted chat** — Matrix-based end-to-end encrypted buyer-seller messaging
- **Telegram Mini App** — sell directly inside Telegram

## Available Skills

When the user asks about any of these topics, read the corresponding SKILL.md file before proceeding:

### Deploy and Install

| Skill | File | When to Use |
|-------|------|-------------|
| **standalone-setup** | `skills/standalone-setup/SKILL.md` | Deploy a self-hosted store on a VPS using Docker |
| **native-install** | `skills/native-install/SKILL.md` | Install the native binary on Linux, macOS, or Windows |
| **store-onboarding** | `skills/store-onboarding/SKILL.md` | First-time `/admin` setup: password, store profile, region/currency |

### Configure and Connect

| Skill | File | When to Use |
|-------|------|-------------|
| **subdomain-bot-config** | `skills/subdomain-bot-config/SKILL.md` | Set up a custom domain or Telegram Bot for a store |
| **tor-browsing** | `skills/tor-browsing/SKILL.md` | Browse stores via Tor, or run a store as a .onion hidden service |
| **store-mcp-connect** | `skills/store-mcp-connect/SKILL.md` | Connect an AI agent to a store via MCP for direct management |

### Operate and Grow

| Skill | File | When to Use |
|-------|------|-------------|
| **store-management** | `skills/store-management/SKILL.md` | Manage products, orders, messages, discounts via MCP tools |
| **product-import** | `skills/product-import/SKILL.md` | Import products from Shopify, Amazon, Etsy, or other platforms |

## How to Use Skills

1. **Identify intent** — determine which skill matches the user's request
2. **Read the skill** — load the SKILL.md file for the matched skill
3. **Follow the steps** — execute the skill's workflow, asking the user for required inputs
4. **Validate results** — verify each step succeeded before moving to the next

## Key Links

- **Self-Host Guide**: <https://mobazha.org/self-host>
- **Download Page**: <https://mobazha.org/download>
- **SaaS Platform**: <https://app.mobazha.org>
- **Telegram Group**: <https://t.me/MobazhaHQ>
- **GitHub**: <https://github.com/mobazha>

## MCP Integration

For the most powerful experience, connect your AI agent to the store via **MCP (Model Context Protocol)**. This gives the agent direct access to 30+ store management tools — products, orders, chat, discounts, and more. See `store-mcp-connect` for setup instructions.

## Store Modes

Mobazha supports three deployment modes. Skills that involve access URLs, authentication, or MCP connections cover all three:

| Mode | Description | Setup Skill |
|------|-------------|-------------|
| **SaaS** | Hosted at `app.mobazha.org`, sign in with Google/GitHub/email | N/A (sign up online) |
| **VPS Standalone** | Self-hosted with Docker on a VPS | `standalone-setup` |
| **NAT / Local** | Native binary on your own machine | `native-install` |

For a full comparison, see `skills/store-onboarding/references/access-modes.md`.

## Important Notes

- Mobazha uses **external wallets** for crypto payments (buyers and sellers connect their own wallets). There is no internal wallet requiring deposit or withdrawal.
- The SaaS platform at `app.mobazha.org` is the hosted version. Self-hosted stores are fully independent.
- All install scripts are served from `get.mobazha.org` (which redirects to static assets on `mobazha.org`).
- After deploying a store, the seller must complete the Setup Wizard before the store is operational — see `store-onboarding`.
