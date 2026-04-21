# Contributing to Mobazha Skills

Thank you for your interest in contributing! This project provides AI agent skills for the Mobazha decentralized commerce platform. Contributions of new skills, improvements to existing ones, and bug fixes are all welcome.

## Skill Directory Structure

Each skill lives in its own directory under `skills/`:

```
skills/
  my-skill/
    SKILL.md          # Required: the skill content
    references/       # Optional: supporting reference files
      some-table.md
      some-mapping.md
```

- **`SKILL.md`** is the main file that AI agents read and follow
- **`references/`** contains supplementary data (field mappings, flag tables, etc.) that the skill cross-references

## Writing Principles

### 1. Write for End Users

Skills are for **sellers, buyers, and store operators** — not developers. Use plain language. Assume the reader has basic computer skills but is not a programmer.

### 2. Every Command Must Work

If a skill includes a shell command or API call, it must be copy-pasteable and produce the expected result. Use `<placeholder>` syntax for values the user must fill in, and explain each placeholder in the surrounding text.

### 3. Cover All Store Modes

When a skill involves access URLs, authentication, or MCP connections, it must address all three deployment modes:

- **SaaS** (`app.mobazha.org`) — OAuth login (Google/GitHub/email)
- **VPS Standalone** — self-hosted with Docker, admin password + Bearer Token
- **NAT / Local** — native binary on a local machine, same auth as VPS

See `skills/store-onboarding/references/access-modes.md` for the full comparison.

### 4. Use Correct API Conventions

- API paths use the `/v1/` prefix (e.g., `/v1/listings`, `/v1/profiles`)
- Authentication uses **Bearer Token** in the `Authorization` header
- Media uploads use `POST /v1/media` with JSON body containing base64 image data

### 5. Cross-Reference Other Skills

Don't duplicate content. If another skill covers a prerequisite, reference it by name:

> "Complete the store setup first — see the `store-onboarding` skill."

### 6. Update the Index

When adding a new skill, add it to the skill table in `skills/using-mobazha/SKILL.md`. Place it in the appropriate category (Deploy and Install / Configure and Connect / Operate and Grow).

## How to Contribute

### Adding a New Skill

1. **Fork** the repository and create a branch
2. Create a new directory: `skills/your-skill-name/`
3. Write `SKILL.md` following the principles above
4. Add the skill to the index in `skills/using-mobazha/SKILL.md`
5. Test by following your own skill's steps on a real Mobazha store (see `TESTING.md`)
6. Submit a **Pull Request** with a clear description of what the skill does

### Improving an Existing Skill

1. Identify the issue (wrong command, missing mode, unclear step)
2. Make the fix
3. Verify the fix works on a real store
4. Submit a PR describing the issue and the fix

### Reporting Issues

If you find an error in a skill (wrong API path, outdated command, missing step), please [open an issue](https://github.com/mobazha/mobazha-skills/issues) with:

- Which skill has the problem
- What the skill says vs. what actually happens
- Your store mode (SaaS / VPS / Local)

## Pull Request Checklist

Before submitting:

- [ ] `SKILL.md` follows the writing principles above
- [ ] All commands and API calls are verified to work
- [ ] All three store modes are addressed (where relevant)
- [ ] Placeholders use `<description>` format and are explained
- [ ] Cross-references to other skills are correct
- [ ] `skills/using-mobazha/SKILL.md` index is updated (for new skills)
- [ ] No internal implementation details are exposed (internal service names, ports, infrastructure)

## Code of Conduct

Be respectful and constructive. We're building tools to help people sell freely on the internet.
