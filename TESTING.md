# Testing Skills

Every skill in this repository should be verified against a real Mobazha store before release. This document explains how to validate that skills are accurate and functional.

## Verification Principle

**If you can't copy-paste a command from a skill and get the expected result, the skill is broken.**

Every API path, shell command, and workflow described in a skill must produce the documented outcome on a real store.

## Setting Up a Test Store

You need at least one Mobazha store to test against. Two options:

### Option 1: SaaS (Quickest)

1. Go to `app.mobazha.org` and sign up with Google, GitHub, or email
2. Complete the onboarding wizard
3. You now have a live store for testing SaaS-mode skills

### Option 2: Self-Hosted (VPS or Local)

Follow the `standalone-setup` or `native-install` skill to deploy a store:

- **VPS**: Any cloud VM with Docker installed
- **Local**: Run the native binary on your machine

This lets you test standalone-mode skills, onboarding, and MCP connections.

## Skill Verification Checklist

### standalone-setup

- [ ] Run the install script on a fresh VPS (or local Docker)
- [ ] Verify the health endpoint responds: `curl http://localhost/healthz`
- [ ] Verify `/admin` shows the Setup Wizard
- [ ] Verify install flags from `references/install-flags.md` are accepted

### native-install

- [ ] Run the install command on the target OS
- [ ] Verify the binary starts: `mobazha start`
- [ ] Verify `/admin` is accessible at `http://localhost/admin`

### store-onboarding

- [ ] **SaaS**: Sign up and verify the UI wizard steps match the skill description
- [ ] **Standalone**: `POST /v1/system/setup` sets password successfully
- [ ] **Standalone**: `GET /v1/system/setup` returns correct `completedSteps`
- [ ] **Standalone**: `PUT /v1/profiles` and `PUT /v1/settings` work with Bearer Token
- [ ] After all steps, `setupComplete` is `true`

### store-mcp-connect

- [ ] Build or install `mobazha-mcp`
- [ ] **SaaS**: Obtain a token via `POST /platform/v1/auth/tokens` (or Admin > AI Agents)
- [ ] **Standalone**: Obtain a token via `POST /v1/auth/tokens` (or Admin > AI Agents)
- [ ] **Local MCP**: Streamable HTTP at `http://localhost:5102/v1/mcp` connects successfully
- [ ] **SSH tunnel**: Tunnel to a remote VPS, then connect via stdio
- [ ] **Remote MCP**: Connect to `https://<domain>/v1/mcp` with Bearer header
- [ ] Agent can call `listings_list_mine` and get a response

### store-management

- [ ] Create a test listing via `listings_create`
- [ ] Update it via `listings_update`
- [ ] Delete it via `listings_delete`
- [ ] List orders via `orders_get_sales`
- [ ] Send a chat message via `chat_send_message`

### product-import

- [ ] Export a CSV from Shopify (or create a sample one)
- [ ] Verify field mapping in `references/shopify-csv-mapping.md` is correct
- [ ] Upload an image via `POST /v1/media`
- [ ] Create a listing via `POST /v1/listings` with the mapped fields

### subdomain-bot-config

- [ ] Configure a custom domain and verify HTTPS works
- [ ] Create a Telegram Bot and verify the webhook connects

### tor-browsing

- [ ] Access a `.onion` store URL via Tor Browser
- [ ] Verify the browsing instructions work on at least one OS

## Reporting Verification Results

After testing, note any discrepancies:

- **API path changed**: The backend may have updated an endpoint
- **Auth method changed**: Token format or obtaining method may have evolved
- **Command fails**: Install scripts or CLI flags may have been updated
- **Missing step**: A prerequisite not mentioned in the skill

File issues at [github.com/mobazha/mobazha-skills/issues](https://github.com/mobazha/mobazha-skills/issues) with the skill name, expected behavior, and actual behavior.

## Verification Cadence

- **Before each release**: All skills should be verified
- **After backend updates**: Re-verify skills that reference changed APIs
- **After new skill additions**: Verify the new skill before merging
