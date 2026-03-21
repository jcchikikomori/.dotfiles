# Opencode Configuration

This directory contains [opencode](https://opencode.ai) configuration files that are stowed to `~/.config/opencode/`.

## Files

| File | Purpose |
|------|---------|
| `opencode.jsonc` | Main config: MCPs, provider, permissions |
| `AGENTS.md` | Global agent instructions |
| `.env.example` | Template for MCP environment variables |
| `.env` | **Local-only** (gitignored) — your actual tokens |

## Setup

1. Copy the example env file:

   ```sh
   cp ~/.config/opencode/.env.example ~/.config/opencode/.env
   ```

2. Edit `~/.config/opencode/.env` and fill in your tokens:

   ```sh
   GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxxxxxxxxxx
   STACK_EXCHANGE_API_KEY=your_key_here
   # ... etc
   ```

3. Restart your shell (or `source ~/.profile`) to load the env vars.

4. Enable MCPs in `opencode.jsonc` by setting `"enabled": true`.

## MCP Token Requirements

| MCP | Required Env Vars | How to Get |
|-----|-------------------|------------|
| `github` | `GITHUB_PERSONAL_ACCESS_TOKEN` | [GitHub Settings → Developer settings → PAT](https://github.com/settings/tokens) |
| `stackoverflow-mcp` | `STACK_EXCHANGE_API_KEY` | [Stack Apps → Register](https://stackapps.com/apps/oauth/register) |
| `framelink-figma` | `FIGMA_API_KEY` | [Figma Settings → Personal Access Tokens](https://www.figma.com/developers/api#access-tokens) |
| `atlassian-mcp` | `JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN`, `CONFLUENCE_URL`, `CONFLUENCE_USERNAME`, `CONFLUENCE_API_TOKEN` | [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens) |
| `sonarqube-mcp` | `SONARQUBE_TOKEN`, `SONARQUBE_URL` | Your SonarQube instance → My Account → Security |

## How It Works

The `.env` file is sourced automatically by `~/.profile` on shell startup:

```sh
if [ -f "$HOME/.config/opencode/.env" ]; then
    set -a  # Auto-export all variables
    . "$HOME/.config/opencode/.env"
    set +a
fi
```

This makes the tokens available as environment variables, which opencode reads via `{env:VARIABLE_NAME}` syntax in `opencode.jsonc`.

## Per-Project Configuration

You can override the global config for a specific project by placing an `opencode.jsonc` in the project root or inside a `.opencode/` directory:

```text
your-project/
├── opencode.jsonc          # project-level config (option A)
└── .opencode/
    └── opencode.jsonc      # project-level config (option B)
```

Opencode merges configs in this order (last wins):

1. `~/.config/opencode/opencode.jsonc` — global (this dotfile)
2. `<project-root>/opencode.jsonc` or `<project-root>/.opencode/opencode.jsonc` — project-level

### Minimal project config example

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "AGENTS.md"         // project-specific agent instructions
  ],
  "mcp": {
    "sonarqube-mcp": {
      "enabled": true   // enable only for this project
    }
  }
}
```

### Committing project configs

- **Do commit** `opencode.jsonc` / `.opencode/opencode.jsonc` — it's safe (no secrets).
- **Never commit** `.env` files — tokens go in `~/.config/opencode/.env` or a local `.opencode/.env` that is gitignored.

Add this to your project's `.gitignore`:

```bash
.opencode/.env
```

## Security Notes

- `.env` is gitignored via `**/.config/**/.env` pattern
- Never commit tokens to git
- Use separate tokens per machine if possible (easier to revoke)
