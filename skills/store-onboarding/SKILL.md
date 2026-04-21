# Store Onboarding

Complete the first-time setup of your Mobazha store after deployment. This skill covers the Setup Wizard and onboarding flow for all store modes.

## Choose Your Mode

| Mode | How You Got Here | What Happens Next |
|------|-----------------|-------------------|
| **SaaS** | Signed up at `app.mobazha.org` | UI-guided wizard after first login |
| **VPS Standalone** | Deployed via `standalone-setup` skill | Setup Wizard at `https://<domain>/admin` |
| **NAT / Local** | Installed via `native-install` skill | Setup Wizard at `http://localhost/admin` |

For a full comparison of access URLs, auth methods, and MCP connections across all modes, see `references/access-modes.md`.

---

## SaaS Mode

For stores on the hosted platform at `app.mobazha.org`:

### Sign In

Go to `app.mobazha.org` and sign in with Google, GitHub, or email. No local password is needed.

### Onboarding Wizard

After first login, the dashboard shows a guided wizard:

1. **Store setup** — name, description, avatar, country, currency, visibility
2. **First product** — prompt to create your first listing
3. **Payments** — link to payment configuration (crypto wallets, Stripe, PayPal)
4. **Launch** — completion screen with your storefront link

The wizard can be **skipped** and dismissed. It reappears until the store has products.

### Notes for AI Agents

SaaS onboarding is UI-driven. Guide the user through the web interface rather than calling APIs directly. The SaaS platform uses OAuth authentication, which differs from the standalone API flow below.

After onboarding, to connect an AI agent for ongoing management, see the `store-mcp-connect` skill (SaaS section).

---

## VPS Standalone Mode

For self-hosted stores deployed on a VPS with Docker.

### Access the Admin Panel

- **With domain**: `https://shop.example.com/admin`
- **Without domain**: `http://<VPS-IP>/admin`

On first visit, the system detects setup is incomplete and shows the **Setup Wizard**.

### Detect Setup Status

Check whether onboarding is complete:

```
GET /v1/system/setup
```

Response:
```json
{
  "setupComplete": false,
  "completedSteps": {
    "password": false,
    "profile": false,
    "preferences": false,
    "payment": false
  }
}
```

### Step 1: Set Admin Password

The first and most critical step. Until a password is set, the store is unsecured.

**Via the UI**: The wizard prompts for a password automatically.

**Via API** (AI agents can automate this):

```
POST /v1/system/setup
Content-Type: application/json

{
  "password": "<strong-password>"
}
```

This endpoint is **public** (no auth required) and can only be called **once**. After the password is set, all endpoints require authentication.

Generate a strong password: at least 12 characters, mixed case, numbers, and symbols.

After setting the password, obtain a Bearer token for subsequent API calls:

```
POST /platform/v1/auth/tokens
Content-Type: application/json

{
  "username": "admin",
  "password": "<your-password>"
}
```

Use the returned token for all subsequent requests:

```
Authorization: Bearer <token>
```

### Step 2: Store Profile

Set your store's identity — name, description, and avatar.

```
PUT /v1/profiles
Content-Type: application/json
Authorization: Bearer <token>

{
  "name": "My Store",
  "shortDescription": "A brief tagline for your store",
  "about": "Longer description about what you sell and your story",
  "avatarHashes": {
    "small": "<image-hash>",
    "medium": "<image-hash>"
  },
  "vendor": true
}
```

To upload an avatar image first:

```
POST /v1/media
Content-Type: application/json
Authorization: Bearer <token>

[{ "image": "<base64-image-data>", "filename": "avatar.jpg" }]
```

### Step 3: Region and Currency

Set your country and display currency for pricing.

```
PUT /v1/settings
Content-Type: application/json
Authorization: Bearer <token>

{
  "country": "US",
  "localCurrency": "USD"
}
```

Common country/currency pairs:

| Country | Code | Currency |
|---------|------|----------|
| United States | US | USD |
| United Kingdom | GB | GBP |
| European Union | DE/FR/etc. | EUR |
| Japan | JP | JPY |
| China | CN | CNY |
| Canada | CA | CAD |
| Australia | AU | AUD |

### Step 4: Setup Complete

After completing steps 1-3, `GET /v1/system/setup` will return `setupComplete: true`. The dashboard is now accessible.

**Recommended next steps** (tell the user about these):

1. **Configure payment methods** — `/admin/settings/payments` to enable crypto wallets and/or fiat providers (Stripe, PayPal)
2. **Add your first product** — `/admin/products/new` to create a listing
3. **Customize your storefront** — `/admin/settings/storefront` to adjust theme and branding
4. **Set up a domain** — If not done during deployment, see the `subdomain-bot-config` skill
5. **Connect an AI agent** — See the `store-mcp-connect` skill to let your AI agent manage the store directly

---

## NAT / Local Mode

For stores running on your local machine (native binary or Docker without a public IP).

### Access the Admin Panel

- **Same machine**: `http://localhost/admin`
- **Other devices on LAN**: `http://<your-local-ip>/admin` (e.g., `http://192.168.1.100/admin`)

If using the native binary with a custom gateway port:
- **Gateway API**: `http://localhost:8100` (default for native)
- **Web UI**: `http://localhost` (default port 80)

### Onboarding Steps

The Setup Wizard is identical to VPS Standalone mode (Steps 1-4 above). The only differences:

- **No domain needed** — You access via `localhost` or LAN IP
- **No HTTPS** — Local connections use HTTP (this is fine for LAN)
- **MCP connects directly** — No SSH tunnel needed: `mobazha-mcp --gateway-url http://localhost:8100`

### Limitations

- Only accessible within your local network
- External buyers cannot reach your store unless you enable:
  - **Tor hidden service** — See `tor-browsing` skill for `.onion` access
  - **P2P network** — Other Mobazha nodes can discover you via the decentralized network
  - **Port forwarding** — Manual router configuration (not recommended for beginners)

---

## Troubleshooting

### "Setup already complete" error on POST /v1/system/setup
The password was already set. Use your existing credentials to obtain a Bearer token and proceed with profile and settings.

### Forgot admin password (standalone / local)
For Docker standalone stores:
```bash
cd /opt/mobazha
docker compose exec mobazha mobazha reset-password
```

For native binary:
```bash
mobazha reset-password
```

### Wizard keeps showing after completing steps
Verify all required steps via `GET /v1/system/setup`. The `profile` step requires a non-empty store `name`. Check that the profile was saved successfully.

### Cannot access from another device on LAN
- Ensure no firewall is blocking the web port (80 or custom)
- Use your machine's LAN IP, not `localhost` (check with `ip addr` or `ifconfig`)
- The store must be running (`mobazha status` or `docker compose ps`)
