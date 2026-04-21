# Mobazha Skills

AI-powered skills for Mobazha — the decentralized commerce platform. Whether you're setting up a self-hosted store, importing products, or configuring privacy tools, these skills guide your AI coding agent through every step.

## What's Inside

| Skill | Description |
|-------|-------------|
| **standalone-setup** | Deploy a self-hosted Mobazha store on any VPS with Docker |
| **native-install** | Install the native binary on Linux, macOS, or Windows |
| **subdomain-bot-config** | Set up a custom domain and Telegram Bot for your store |
| **tor-browsing** | Configure Tor Browser to access .onion stores privately |
| **product-import** | Import products from Shopify, Amazon, or Etsy into your store |

## Installation

### Claude Code (Official Marketplace)

```
/plugin install mobazha-skills@claude-plugins-official
```

### Claude Code (Mobazha Marketplace)

```
/plugin marketplace add mobazha/mobazha-skills
/plugin install mobazha-skills@mobazha-skills
```

### Cursor

```
/add-plugin mobazha-skills
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
  "plugin": ["mobazha-skills@git+https://github.com/mobazha/mobazha-skills.git"]
}
```

### Gemini CLI

```
gemini extensions install https://github.com/mobazha/mobazha-skills
```

### OpenClaw

```
openclaw plugins install mobazha-skills
```

## How It Works

Once installed, your AI agent automatically discovers Mobazha skills. Ask it things like:

- "Help me set up a self-hosted Mobazha store on my VPS"
- "Install Mobazha on my Mac"
- "Import my Shopify products into Mobazha"
- "Configure Tor to browse Mobazha stores privately"
- "Set up a custom domain and Telegram bot for my store"

The agent loads the relevant skill and walks you through the process step by step.

## About Mobazha

[Mobazha](https://mobazha.org) is a decentralized commerce platform for independent sellers. Zero commissions, built-in escrow protection, crypto + fiat payments, and full data sovereignty.

- **Website**: https://mobazha.org
- **Self-Host Guide**: https://mobazha.org/self-host
- **Telegram**: https://t.me/MobazhaHQ
- **GitHub**: https://github.com/mobazha

## License

MIT License — see [LICENSE](LICENSE) for details.
