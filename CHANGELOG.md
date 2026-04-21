# Changelog

All notable changes to this project will be documented in this file.

## [0.3.0] - 2026-04-21

### Added
- **Access modes reference**: comparison table for SaaS / VPS / NAT store modes
- **CONTRIBUTING.md**: skill contribution guidelines and PR checklist
- **TESTING.md**: skill verification guide with per-skill checklists
- **CHANGELOG.md**: version history
- **GitHub Actions CI**: Markdown lint and link checking
- **Internal AI rules**: CLAUDE.md and Cursor rules for skill authoring

### Changed
- **store-onboarding**: restructured with "Choose Your Mode" navigation covering SaaS, VPS, and NAT/Local modes; removed internal implementation references
- **store-mcp-connect**: reorganized by deployment scenario (Local / Remote VPS / SaaS) instead of transport protocol; corrected auth from Basic Auth to Bearer Token
- **README**: added CI badge, Contributing/Testing links, full skill listing with categories

### Fixed
- MCP authentication: corrected from Base64 Basic Auth to Bearer Token via `/platform/v1/auth/tokens`
- SaaS mode: replaced internal auth provider references with "OAuth login (Google/GitHub/email)"

## [0.2.0] - 2026-04-21

### Added
- **store-onboarding**: first-time `/admin` setup wizard walkthrough
- **store-mcp-connect**: connect AI agents to stores via MCP (stdio + SSE)
- **store-management**: 30+ MCP tool usage guide organized by seller workflows
- MCP server declarations in Claude and Cursor plugin manifests

### Changed
- **standalone-setup**: Step 4 now references store-onboarding skill
- **native-install**: added onboarding and MCP references
- **using-mobazha**: restructured index into Deploy / Configure / Operate categories
- **README**: added MCP integration section

## [0.1.0] - 2026-04-21

### Added
- Initial release with 5 skills:
  - **standalone-setup**: deploy a self-hosted store with Docker
  - **native-install**: install the native binary
  - **subdomain-bot-config**: custom domain and Telegram Bot setup
  - **tor-browsing**: Tor Browser configuration and .onion hidden services
  - **product-import**: import products from Shopify, Amazon, Etsy
- Plugin manifests for Claude Code, Cursor, Codex, OpenCode, Gemini, OpenClaw, GitHub Copilot
- Session start hooks for skill auto-discovery
