# OpenCode Integration for .dotfiles

This directory contains OpenCode agent configuration for managing this dotfiles repository with an AI-powered orchestrator/maintainer system.

## Overview

OpenCode provides an agentic workflow system that combines:
- **Orchestrator agent** — primary interface for user requests
- **Maintainer agent** — specialized subagent for cross-platform maintenance
- **MCP servers** — integrated tools for GitHub, Stack Overflow, and web search

## Project Structure

```
.opencode/
├── agents/
│   ├── dotfiles-orchestrator.md    # Primary agent instructions
│   └── dotfiles-maintainer.md     # Maintenance subagent instructions
├── opencode.jsonc                  # OpenCode configuration
├── package.json                    # Node.js dependencies
└── node_modules/                   # Installed dependencies
```

## Agent System

### Orchestrator (Primary Agent)

The orchestrator is the **default agent** activated when opening this project in OpenCode. It:

1. **Classifies requests** using a decision tree
2. **Answers directly** for architectural/conventional questions
3. **Clarifies ambiguity** before delegating (distro, package, scope)
4. **Delegates to maintainer** for maintenance tasks
5. **Summarizes results** in human-friendly format

**Permission Model:**
| Category | Permission |
|---|---|
| Read-only git | `git status`, `git log`, `git diff`, `git show`, `git blame` |
| Interactive git | `git commit`, `git push`, `git pull` (ask first) |
| Dangerous | `rm -rf`, destructive git (ask first) |
| Web fetch | Allowed |
| Task delegation | Can spawn `dotfiles-maintainer` |

### Maintainer (Subagent)

The maintainer handles **all cross-platform maintenance work**:

| Capability | Description |
|---|---|
| Cross-distro propagation | Debian, Ubuntu, Arch, SteamOS, RHEL, Termux, macOS |
| ARM compatibility | Raspberry Pi, Apple Silicon, mobile devices |
| Stow conflict detection | Pre-cleanup validation |
| Script refactoring | POSIX compliance (no bash-specific syntax) |
| Configuration validation | `setup.sh`, `stowme.sh` changes |
| GitHub issue triage | Severity, affected distros, suggested fixes |

**Permission Model:**
| Category | Permission |
|---|---|
| File editing | Allowed |
| Bash commands | Allowed (except destructive) |
| Git write operations | Ask first |
| GitHub operations | Read-only; write ops require confirmation |

## MCP Servers

The following MCP servers are configured in `opencode.jsonc`:

### Enabled

| Server | Purpose | Use Case |
|---|---|---|
| `github-mcp` | GitHub API integration | Issues, PRs, repos, search |
| `stackoverflow-mcp` | Stack Overflow search | Error resolution, best practices |

### Disabled (Available)

| Server | Purpose | Enable in `opencode.jsonc` |
|---|---|---|
| `framelink-figma` | Figma integration | UI design handoffs |
| `atlassian-mcp` | Jira/Confluence | Issue tracking |
| `sonarqube-mcp` | Code quality | Static analysis |

## Decision Tree

When you make a request, the orchestrator routes it like this:

```
Your Request
│
├── "What does X do?" / "Where is Y?" / "How does Z work?"
│   └── Answered directly by orchestrator
│
├── "Add / fix / change / validate something"
│   ├── Orchestrator asks for clarification if needed
│   └── Delegated to maintainer with precise task description
│
├── "Check stow conflicts" / "Pre-cleanup check"
│   └── Delegated to maintainer
│
├── "Look at GitHub issues" / "Triage this bug"
│   └── Delegated to maintainer
│
└── "Run stowme.sh" / "Re-stow packages"
    ├── Orchestrator confirms distro + packages
    └── Delegated to maintainer
```

## Common Tasks

### Propagate a Change Across Distros

```
You: "Propagate the starship config change to all distros"
Orchestrator: "Which specific change? A new setting or full file replacement?"
You: "New tmux integration setting in starship.toml"
Orchestrator → Maintainer:
  "Propagate the tmux integration setting in linux/starship/config.toml
   to ensure it works on Debian, Arch, RHEL, and macOS. Validate with
   shellcheck. Do not commit."
```

### Pre-Stow Conflict Check

```
You: "Check for stow conflicts before re-stowing everything"
Orchestrator → Maintainer:
  "Run a pre-stow conflict check for all packages on the current distro.
   Report blocking conflicts and recommended actions. Dry-run only."
```

### GitHub Issue Triage

```
You: "Triage the open GitHub issues"
Orchestrator → Maintainer:
  "Use github-mcp tools to read all open issues. For each issue, provide:
   - Severity (Low/Medium/High)
   - Affected distros
   - Suggested fix
   Format as structured report. Do not comment or close anything."
```

### GitHub Write Operation Safety Check

Before any write operation (create/update issue/PR, comment, merge), agents must:

1. Call `github-mcp_get_me`
2. Report the returned login
3. Ask for confirmation before writing

`gh` CLI is fallback-only and used only when explicitly requested by the user or MCP is unavailable.

### Script Validation

```
You: "Validate the debian/setup.sh changes before committing"
Orchestrator → Maintainer:
  "Run shellcheck -s sh on debian/setup.sh.
   Check for POSIX compliance.
   Run syntax check: sh -n debian/setup.sh
   Report any errors or warnings."
```

### Documentation Update Check

```
You: "I added a new stow package called 'supermodel'"
Orchestrator → Maintainer:
  "Update docs/STOW_PACKAGES.md with the new 'supermodel' package entry.
   Include: name, description, platforms.
   Also update README.MD if the Features section needs updating."
```

## Distro Families Reference

| Family | Directories | Package Manager | Special Notes |
|---|---|---|---|
| Debian | `debian/`, `ubuntu/` | apt | Standard Linux support |
| Arch | `arch/`, `steamos/` | pacman + yay | Steam Deck uses this |
| RHEL | `rhel/` | dnf | Fedora, CentOS compatible |
| Termux | `termux/` | pkg | ARM-only, no sudo |
| macOS | `darwin/` | brew | Apple Silicon + Intel |

## Architecture Support

| Arch | Support Level | Notes |
|---|---|---|
| x86_64 | Full | All features available |
| ARM (Apple Silicon) | Full | ARM-compatible binaries required |
| ARM (aarch64/Termux) | Limited | Python/pyenv only |
| ARM (armv7) | Minimal | Check binary availability |

## Constraints

The maintainer operates under these constraints:

- ❌ Never rename existing script files (referenced by CI)
- ❌ Never change the `$HOME/.dotfiles` hardcoded path
- ❌ Never use bash-specific syntax — POSIX `#!/bin/sh` only
- ❌ Never modify `stowme.sh` package lists without updating ALL distro wrappers
- ✅ Always confirm before `git commit`, `git push`, or destructive operations
- ✅ Always check `SKIP_INSTALL_PROGLANG` for unattended mode
- ✅ **Always update docs/ when making changes that affect user behavior**

## Git Safety Protocol

The orchestrator and maintainer will **always** ask before executing:

| Command | Impact |
|---|---|
| `git commit` | Creates new commit with your changes |
| `git push` | Sends commits to remote |
| `git reset --hard` | Discards uncommitted changes |
| `git clean -fd` | Removes untracked files/dirs |
| `git rebase -i` | Rewrites commit history |

Read-only commands (git status, log, diff, show, blame) execute automatically.

## Getting Help

### Within OpenCode

Simply ask natural language questions:

- "How does stowme.sh work?"
- "Where is the zsh config for Arch?"
- "What's the setup process for Steam Deck?"
- "Show me the recent commits"

### Quick Reference

| Concern | Ask |
|---|---|
| Project structure | Orchestrator (direct) |
| Adding a new package | Maintainer |
| Stow conflicts | Maintainer |
| CI/CD questions | Orchestrator (direct) |
| ARM compatibility | Maintainer |
| GitHub issues | Maintainer |

## Configuration Files

### `opencode.jsonc`

```jsonc
{
  "provider": {
    "github-copilot": {}  // AI provider configuration
  },
  "mcp": {
    "github": { "enabled": true },              // GitHub integration
    "stackoverflow-mcp": { "enabled": true },  // SO search
    // Add more MCP servers as needed
  }
}
```

### Agent Files

- `agents/dotfiles-orchestrator.md` — Orchestrator instructions
- `agents/dotfiles-maintainer.md` — Maintainer instructions

To modify agent behavior, edit the corresponding markdown file. Changes take effect on next OpenCode session.

## Troubleshooting

### Agent Not Responding Correctly

1. Check that `agents/dotfiles-orchestrator.md` exists
2. Verify `mode: primary` is set for orchestrator
3. Ensure YAML frontmatter is valid

### MCP Commands Not Working

1. Confirm server is `"enabled": true` in `opencode.jsonc`
2. Check that `node_modules` contains the MCP package
3. Restart OpenCode session

### Git Commands Being Denied

1. Verify the command matches the permission pattern
2. Provide explicit confirmation when asked
3. Check that orchestrator/maintainer modes have correct bash permissions
