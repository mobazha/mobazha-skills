# Mobazha Skills — Authoring Rules

This repository contains AI agent skills for the Mobazha decentralized commerce platform. Follow these rules when editing any skill content.

## Core Constraints

1. **Face end users, not developers.** Skills are for sellers, buyers, and store operators. Write as if explaining to someone who can follow instructions but is not a programmer.

2. **Never expose internal implementation details.** Do not mention internal service names, identity providers, internal port mappings, Docker compose service names, internal database names, or any other infrastructure detail. Use user-facing terminology only:
   - Say "OAuth login (Google/GitHub/email)" — not the name of the identity provider
   - Say "Bearer Token" — not how the token is internally validated
   - Say "store gateway" — not internal service names or process names

3. **Authentication conventions:**
   - SaaS mode: "Sign in with Google, GitHub, or email"
   - Standalone / Local mode: "admin password" → obtain a Bearer Token via `POST /platform/v1/auth/tokens`
   - All API calls use `Authorization: Bearer <token>` — never Basic Auth in user-facing docs

4. **API path conventions:**
   - All paths use the `/v1/` prefix (e.g., `/v1/listings`, `/v1/profiles`)
   - MCP auth tokens from `/platform/v1/auth/tokens`
   - MCP SSE endpoint at `/platform/v1/mcp`
   - Media uploads via `POST /v1/media` (JSON body with base64)

5. **Cover all three store modes** when the skill involves access URLs, authentication, or MCP:
   - SaaS (`app.mobazha.org`)
   - VPS Standalone (Docker, public IP / domain)
   - NAT / Local (native binary, no public IP)
   See `skills/store-onboarding/references/access-modes.md` for the full comparison.

6. **Commands must be copy-pasteable.** Use `<placeholder>` format for user-supplied values and explain each placeholder in surrounding text.

7. **Cross-reference, don't duplicate.** If another skill covers a topic, reference it by name instead of repeating content.

8. **Update the index.** When adding or renaming a skill, update `skills/using-mobazha/SKILL.md` with the correct entry in the appropriate category.

## Skill File Structure

```
skills/
  skill-name/
    SKILL.md          # Required
    references/       # Optional
      data-table.md
```

## Quality Checks

Before committing, verify:

- [ ] No internal service names, provider names, or infrastructure details
- [ ] API paths start with `/v1/` or `/platform/v1/`
- [ ] Auth uses Bearer Token (not Basic Auth)
- [ ] All three modes addressed where relevant
- [ ] `using-mobazha/SKILL.md` index is up to date
- [ ] Commands work when copy-pasted on a real store
