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

| Skill | File | When to Use |
|-------|------|-------------|
| **standalone-setup** | `skills/standalone-setup/SKILL.md` | User wants to deploy a self-hosted store on a VPS using Docker |
| **native-install** | `skills/native-install/SKILL.md` | User wants to install the native binary on Linux, macOS, or Windows |
| **subdomain-bot-config** | `skills/subdomain-bot-config/SKILL.md` | User wants to set up a custom domain or Telegram Bot for their store |
| **tor-browsing** | `skills/tor-browsing/SKILL.md` | User wants to browse Mobazha stores via Tor, or run a store as a .onion hidden service |
| **product-import** | `skills/product-import/SKILL.md` | User wants to import products from Shopify, Amazon, Etsy, or other platforms |

## How to Use Skills

1. **Identify intent** — determine which skill matches the user's request
2. **Read the skill** — load the SKILL.md file for the matched skill
3. **Follow the steps** — execute the skill's workflow, asking the user for required inputs
4. **Validate results** — verify each step succeeded before moving to the next

## Key Links

- **Self-Host Guide**: https://mobazha.org/self-host
- **Download Page**: https://mobazha.org/download
- **SaaS Platform**: https://app.mobazha.org
- **Telegram Group**: https://t.me/MobazhaHQ
- **GitHub**: https://github.com/mobazha

## Important Notes

- Mobazha uses **external wallets** for crypto payments (buyers and sellers connect their own wallets). There is no internal wallet requiring deposit or withdrawal.
- The SaaS platform at `app.mobazha.org` is the hosted version. Self-hosted stores are fully independent.
- All install scripts are served from `get.mobazha.org` (which redirects to static assets on `mobazha.org`).
