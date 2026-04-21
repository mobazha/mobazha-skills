# Mobazha Skills — OpenCode Installation

## Auto-Install (Recommended)

Add to your `opencode.json`:

```json
{
  "plugin": ["mobazha-skills@git+https://github.com/mobazha/mobazha-skills.git"]
}
```

OpenCode will clone the repo and load the plugin automatically.

## Manual Install

```bash
git clone https://github.com/mobazha/mobazha-skills.git ~/.mobazha-skills
```

Then add to `opencode.json`:

```json
{
  "plugin": ["mobazha-skills@~/.mobazha-skills"]
}
```
