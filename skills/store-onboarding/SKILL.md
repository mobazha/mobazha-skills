# Store Onboarding

Complete the first-time setup of your Mobazha store after deployment. This skill covers the Setup Wizard that appears when you first visit `/admin`.

## How It Works

When you first open your store's admin panel (`/admin`), the system detects that setup is incomplete and shows a **Setup Wizard** instead of the dashboard. The wizard must be completed before you can manage your store.

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

When `setupComplete` is `true`, the wizard is done and the dashboard loads normally.

## Setup Wizard Steps (Standalone Mode)

### Step 1: Set Admin Password

The first and most critical step. Until a password is set, the store is unsecured.

**Via the UI**: Open `http://<store-url>/admin` and the wizard prompts for a password.

**Via API** (AI agent can do this directly):

```
POST /v1/system/setup
Content-Type: application/json

{
  "password": "<strong-password>"
}
```

This endpoint is **public** (no auth required) and can only be called **once**. After the password is set, this endpoint requires authentication.

Generate a strong password: at least 12 characters, mixed case, numbers, and symbols.

After setting the password, authenticate all subsequent requests with HTTP Basic Auth:

```
Authorization: Basic <base64(admin:password)>
```

### Step 2: Store Profile

Set your store's identity — name, description, and avatar.

```
PUT /v1/profiles
Content-Type: application/json
Authorization: Basic <base64(admin:password)>

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
Authorization: Basic <base64(admin:password)>

[{ "image": "<base64-image-data>", "filename": "avatar.jpg" }]
```

### Step 3: Region and Currency

Set your country and display currency for pricing.

```
PUT /v1/settings
Content-Type: application/json
Authorization: Basic <base64(admin:password)>

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

1. **Configure payment methods** — Go to `/admin/settings/payments` to enable crypto wallets and/or fiat providers (Stripe, PayPal)
2. **Add your first product** — Go to `/admin/products/new` to create a listing
3. **Customize your storefront** — Go to `/admin/settings/storefront` to adjust theme and branding
4. **Set up a domain** — If not done during deployment, see the `subdomain-bot-config` skill
5. **Connect an AI agent** — See the `store-mcp-connect` skill to let your AI agent manage the store directly

## SaaS Mode Onboarding

For stores hosted on the SaaS platform (`app.mobazha.org`), onboarding differs:

1. **Sign up / log in** — Authentication is handled by Casdoor (OAuth), not a local password
2. **OnboardingWizard** — After first login, the dashboard shows a guided wizard:
   - **Store setup**: name, description, avatar, country, currency, visibility
   - **Product**: prompt to create your first listing
   - **Payments**: link to payment configuration
   - **Launch**: completion screen with storefront link
3. The wizard can be **skipped** and dismissed — it reappears until the store has products and orders

SaaS onboarding is UI-driven. AI agents should guide the user through the web interface rather than calling APIs directly (the SaaS gateway handles auth differently).

## Troubleshooting

### "Setup already complete" error on POST /v1/system/setup
The password was already set. Use Basic Auth with the existing password to proceed with profile and settings.

### Forgot admin password (standalone)
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
