# OpenCode Model Configuration Best Practices

## Problem: Hardcoded Models Don't Scale

**❌ BAD:** Hardcoding models in agent files or project configs
```json
{
  "model": "github-copilot/claude-sonnet-4.6",
  "default_agent": "obama"
}
```

**Why it breaks:**
- Fails when switching between work (corporate AWS Bedrock) and personal (GitHub Copilot)
- Subagents inherit the hardcoded model and crash with `ProviderModelNotFoundError`
- Can't use different models per environment without editing config files

---

## ✅ Solution: Environment Variable Configuration

### Global Config (`~/.config/opencode/opencode.jsonc`)

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "{env:OPENCODE_MODEL}",
  "small_model": "{env:OPENCODE_SMALL_MODEL}",
  "provider": {
    "amazon-bedrock": {
      "options": {
        "region": "{env:AWS_REGION}",
        "profile": "{env:AWS_PROFILE}"
      }
    },
    "github-copilot": {}
  }
}
```

### Environment Variables (`~/.config/opencode/.env`)

```bash
# Model Configuration
OPENCODE_MODEL=amazon-bedrock/anthropic.claude-sonnet-4-5-20250929-v1:0
OPENCODE_SMALL_MODEL=amazon-bedrock/anthropic.claude-sonnet-4-5-20250929-v1:0

# Amazon Bedrock Provider
AWS_REGION=ap-southeast-2
AWS_PROFILE=rdy-claude
```

### Project Config (`.opencode/opencode.jsonc`)

**Inherit from global:**
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "{env:OPENCODE_MODEL}",
  "small_model": "{env:OPENCODE_SMALL_MODEL}",
  "default_agent": "your-project-agent"
}
```

**Or override for specific project:**
```jsonc
{
  "model": "{env:WORK_PROJECT_MODEL}",
  "default_agent": "your-project-agent"
}
```

---

## Agent Files Best Practice

### ❌ BAD: Hardcoded Models in Agent Markdown

```markdown
## Model

- **Default:** `github-copilot/claude-sonnet-4.6`
- **Small:** `github-copilot/claude-haiku-4.5`
```

### ✅ GOOD: Reference Environment Variables

```markdown
## Model

- Uses environment variable configuration from `~/.config/opencode/.env`
- **Default:** `$OPENCODE_MODEL` (configured in .env)
- **Small:** `$OPENCODE_SMALL_MODEL` (configured in .env)
- This allows the same agent to work across personal and work projects with different model providers
```

---

## Multi-Environment Setup

### Personal Projects (GitHub Copilot)

```bash
# ~/.config/opencode/.env
OPENCODE_MODEL=github-copilot/claude-sonnet-4
OPENCODE_SMALL_MODEL=github-copilot/claude-haiku-4
```

### Work Projects (AWS Bedrock)

```bash
# ~/.config/opencode/.env
OPENCODE_MODEL=amazon-bedrock/anthropic.claude-sonnet-4-5-20250929-v1:0
OPENCODE_SMALL_MODEL=amazon-bedrock/anthropic.claude-sonnet-4-5-20250929-v1:0
AWS_REGION=ap-southeast-2
AWS_PROFILE=rdy-claude
```

### Switch Between Environments

Just update `~/.config/opencode/.env` or use project-specific overrides in `.opencode/.env`

---

## Why This Matters for Subagents

When you call `task(subagent_type="explorer")`, the subagent:

1. **Reads the config hierarchy:**
   - Project `.opencode/opencode.jsonc` (if exists)
   - Global `~/.config/opencode/opencode.jsonc`
   - Agent-specific model hints (should be documentation only)

2. **Resolves environment variables:**
   - `{env:OPENCODE_MODEL}` → reads from shell environment or .env file

3. **Initializes with the resolved model:**
   - If model doesn't exist in provider config → `ProviderModelNotFoundError`

**With hardcoded models:**
- Subagent tries to use `github-copilot/claude-sonnet-4.6`
- Your config only has `amazon-bedrock/...` models
- **CRASH:** `ProviderModelNotFoundError`

**With environment variables:**
- Subagent reads `$OPENCODE_MODEL` → `amazon-bedrock/anthropic.claude-sonnet-4-5...`
- Model exists in your provider config
- **SUCCESS:** Subagent spawns correctly

---

## Quick Migration Checklist

For any project or agent configuration:

- [ ] Replace `"model": "provider/model-name"` with `"model": "{env:OPENCODE_MODEL}"`
- [ ] Replace `"small_model": "provider/model-name"` with `"small_model": "{env:OPENCODE_SMALL_MODEL}"`
- [ ] Add `amazon-bedrock` provider if using AWS Bedrock
- [ ] In agent `.md` files, document model usage but don't specify exact models
- [ ] Set `OPENCODE_MODEL` and `OPENCODE_SMALL_MODEL` in `~/.config/opencode/.env`
- [ ] Test subagent spawning with: `task(subagent_type="explorer", prompt="test")`

---

## Files Updated in This Dotfiles Repo

| File | Change |
|------|--------|
| `linux/opencode/.config/opencode/opencode.jsonc` | Uses `{env:OPENCODE_MODEL}` |
| `linux/opencode/.config/opencode/agents/obama.md` | Documents env var usage, no hardcoded models |
| `.opencode/opencode.jsonc` | Uses `{env:OPENCODE_MODEL}`, added amazon-bedrock provider |
| `~/.config/opencode/opencode.jsonc` | Uses `{env:OPENCODE_MODEL}` (symlinked from stow) |
| `~/.config/opencode/agents/obama.md` | Documents env var usage (symlinked from stow) |
| `~/.config/opencode/.env` | Defines `OPENCODE_MODEL` for your environment |

---

## Testing

After migration, verify subagents work:

```bash
# Start opencode in your dotfiles directory
opencode

# In the opencode session, try spawning a subagent
task(subagent_type="explorer", prompt="Find all setup.sh files")
```

If you see `ProviderModelNotFoundError`, check:
1. `echo $OPENCODE_MODEL` - Is it set?
2. Does the model exist in your `provider` config?
3. Is `amazon-bedrock` provider configured if using Bedrock?
