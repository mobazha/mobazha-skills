# Native Binary Installation

Install Mobazha as a single native binary — no Docker, no runtime dependencies. Works on Linux (x86_64 & ARM64), macOS (Apple Silicon & Intel), and Windows.

**Official guide**: https://mobazha.org/self-host (Native Binary tab) and https://mobazha.org/download

## Quick Install

### Linux & macOS

```bash
curl -sSL https://get.mobazha.org/install | bash
```

This downloads the `mobazha` binary to `~/.local/bin/` (or to a directory on your PATH) and starts the store.

### Windows

1. Go to https://mobazha.org/download
2. Download the `.zip` file for Windows
3. Extract the archive
4. Double-click `mobazha-tray.exe` to start

The Windows desktop app includes a system tray icon and auto-opens your browser to the store admin.

## What the Installer Does

1. Detects your OS and architecture (linux/darwin, amd64/arm64)
2. Downloads the matching binary from GitHub Releases
3. Places it in `~/.local/bin/` (or custom `--dir`)
4. On macOS: includes the desktop tray launcher (system tray icon)
5. Starts the store automatically (unless `--no-start` is passed)

## Running Your Store

### Start with a domain (auto-TLS)

```bash
mobazha start --domain shop.example.com
```

### Start without a domain (localhost / LAN)

```bash
mobazha start
```

The store will be accessible at `http://localhost` or `http://<LAN-IP>`. Buyers can still find you through the Mobazha network even without a public IP.

### Install as a System Service

Linux (systemd) or macOS (launchd):

```bash
sudo mobazha setup-service install
```

This sets up the store to start automatically on boot. Manage with:

```bash
sudo systemctl status mobazha    # Linux
sudo launchctl list | grep mobazha  # macOS
```

## Install Options

| Flag | Description |
|------|-------------|
| `--version <tag>` | Install a specific version (e.g., `v0.3.0-beta.15`) |
| `--dir <path>` | Custom install directory (default: `~/.local/bin`) |
| `--no-start` | Download only, don't start the store |

## Backup

```bash
mobazha backup -o ~/mobazha-backup.tar.gz
```

## Uninstall

Remove the binary and service (keeps your store data):

```bash
curl -sSL https://get.mobazha.org/install | bash -s -- --uninstall
```

Remove everything including data:

```bash
curl -sSL https://get.mobazha.org/install | bash -s -- --uninstall --purge
```

## Platform Notes

### macOS
- Installs via `curl | bash`, which bypasses Gatekeeper (no Apple Developer signing required)
- Includes a desktop tray app with system tray icon
- Supports both Apple Silicon (arm64) and Intel (amd64)

### Linux ARM64
- Works on Raspberry Pi 4+ and ARM VPS instances
- Same install command — the script auto-detects architecture

### Running Behind NAT
- No port forwarding needed for basic operation
- Your store stays reachable via the Mobazha P2P network
- For a direct URL, use `--domain` with a public-facing server, or enable Tor overlay

## After Installation

1. Open `http://localhost/admin` (or `https://your-domain/admin`)
2. Complete the **Setup Wizard** — set admin password, store name, region/currency (see `store-onboarding` skill for the full walkthrough)
3. Add products and start selling
4. (Optional) Connect your AI agent to the store via MCP for hands-free management — see `store-mcp-connect` skill

## Troubleshooting

### Binary not found after install
Ensure `~/.local/bin` is in your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

### Permission denied
The installer needs write access to the install directory. Use `--dir` to specify a writable location, or run with appropriate permissions.

### macOS "unverified developer" warning
This shouldn't happen with `curl | bash` install. If running a downloaded binary directly, use:
```bash
xattr -d com.apple.quarantine ./mobazha
```
