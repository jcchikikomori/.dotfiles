# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cross-platform dotfiles management system. Automates shell/dev environment setup across Debian/Ubuntu, Arch (incl. SteamOS), RHEL/Fedora, macOS, WSL2, and Termux. Configs are symlinked from `linux/*/` package directories into `$HOME` using GNU Stow via the [dotstow](https://github.com/jcchikikomori/dotstow) wrapper.

**Hardcoded paths — do not change:**

- Repo location: `$HOME/.dotfiles`
- Utility scripts: `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/` (stowed to `$HOME/.local/bin/...`)
- Dev tools: `linux/systems/.local/bin/org.jcchikikomori.devtools/bin/`
- Dotstow state: `$HOME/.local/state/dotstow/dotfiles` → symlink to `$HOME/.dotfiles`

## Commands

```sh
# Full setup (fresh machine) — order matters
git submodule update --init --recursive   # required; stow fails on submodule packages otherwise
./start.sh                                # OS detection → {distro}/setup.sh → dotfiles-post-setup
./stowme.sh                               # symlink configs via dotstow (canonical entrypoint)

# Run/test a single post-setup script (same as CI does)
./linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-python install
./linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-nodejs install

# Debian smoke test in Docker (stow workflow end-to-end)
docker compose run --rm dotfiles-ci-debian

# Lint/format (pre-commit: check-yaml, whitespace, json, black)
pre-commit run --all-files
```

There is no unit-test framework. Validation happens through GitHub Actions integration tests (`.github/workflows/ci-unit-test.yml` for ubuntu/arch/fedora, `ci-termux.yml` for simulated Termux) and the Docker smoke test above. CI env vars: `SKIP_SETTING_USER=true`, `SKIP_INSTALL_PROGLANG=false`, `CI=true`.

Commit messages must be conventional-commit format (commitizen enforces via `commit-msg` hook; `cz commit` for a wizard).

## Architecture

**Two-phase setup flow:**

1. `start.sh` — detects distro (writes `$HOME/.dotfiles-distro`; values: `ubuntu`, `debian`, `arch`, `archbtw`, `steamos`, `rhel`, `darwin`, `termux`), runs `{distro}/setup.sh`, then `dotfiles-post-setup` (interactive prompts for pyenv/nvm/rbenv/sdkman etc., skipped when `SKIP_INSTALL_PROGLANG` set).
2. `stowme.sh` — pre-stow cleanup (`dotfiles-cleanup`, `dotfiles-cleanup-bin`, `dotfiles-ssh`, `dotfiles-conflicts`), then `dotstow stow <packages>`. Root `stowme.sh` owns the **only canonical package list** (with a reduced list for `darwin`); `{distro}/stowme.sh` files are compatibility wrappers that must only delegate to root. Handles WSL/CI absolute-symlink traps (`~/.aws`, `~/.azure`, `~/.ghcup`) by removing and restoring them around stow.

**Stow packages** map 1:1 to `linux/{name}/` directories whose internal layout mirrors `$HOME` (e.g. `linux/zsh/.zshrc`). Adding a config: create `linux/{package}/`, add the package name to root `stowme.sh`. Full list in `docs/STOW_PACKAGES.md`.

**Git submodules** (init required before stowing): `linux/opencode`, `linux/claude`, `linux/vscode/.config/Code/User/prompts`, `linux/mpv/.config/mpv`, `linux/neovim/.config/nvim`.

**Distro family propagation:** changes to setup logic usually need mirroring across families — Debian (`debian/`, `ubuntu/`), Arch (`arch/`, `steamos/`), RHEL (`rhel/`), macOS (`darwin/`), Termux (`termux/`). `archbtw` (barebones Arch) additionally runs `arch/init.sh` first (locale, base-devel, yay, Chaotic-AUR).

**Termux constraints:** no sudo, no systemd, `pkg` package manager, `$PREFIX` paths, Bionic libc — only Python/pyenv officially supported there.

## Scripting Conventions

- **POSIX `#!/bin/sh` only** — no bashisms (scripts must run on dash, Termux, macOS sh).
- Utility naming: `dotfiles-{purpose}`; start new scripts from `bin/bin-template` in the same directory.
- **Never rename existing script files** — names are referenced by `dotfiles-post-setup` and CI workflows.
- Keep `SKIP_INSTALL_PROGLANG` unattended-mode checks and the `install` argument support intact in version-manager scripts (CI depends on both).
- Interactive prompts must have a non-interactive escape hatch for CI.

## Branching & PR Workflow

**Branch hierarchy (do not bypass):**

- `master` — release branch, default branch (`origin/HEAD`). **No direct commits.**
- `develop` — active integration branch. **No direct commits.** All work lands here via PR.
- `<type>/<issue#>-<short-desc>` — feature/bugfix branches; fork from `develop`, target `develop` in the PR.
- `release/<version>` — release prep; fork from `develop`, target `master` after stabilisation.

**Branch types:**

- `feature/<issue#>-<slug>` — new functionality or enhancement.
- `bugfix/<issue#>-<slug>` — bug fix.
- `release/<version>` — release preparation.
- `docs/<scope>` — documentation-only changes.

**Naming rules:**

- Always include the GitHub issue number: `bugfix/255-powerline-git-fix`, not `bugfix/powerline-fix`.
- Slug is short, kebab-case, no trailing punctuation.

**PR rules:**

- One PR per logical change. Squash-merge to `develop` cleans the history.
- PR title is the conventional-commit subject; body follows `.github/PULL_REQUEST_TEMPLATE.md`.
- Link the issue with `Closes #<issue-number>` in the PR body.
- CI green before merge. Head branch deleted after squash-merge.
- For larger work, drop a plan at `.omo/plans/<plan-name>.md` and capture evidence at `.omo/evidence/<task>-<short-desc>.diff`; reference both in the PR body's Implementation Checklist.

**Why:** direct commits to `develop` or `master` skip review, bypass the CI gate on the merged commit, and leave no audit trail tying the change back to the issue that motivated it. PRs are cheap; the discipline is not.

## Directory-Specific Notes

- `linux/systems/.local/bin/org.jcchikikomori.dotfiles/CLAUDE.md` — agent notes for the utility-script directory (e.g. `dotfiles-arch` command reference, AUR safety-research requirement).
- `docs/MCP_GITHUB_POLICY.md` — GitHub operations default to GitHub MCP tools; `gh` CLI is fallback only.
- `.github/copilot-instructions.md` — extended agent instructions (CI patterns, Termux gotchas, tmux/zsh plugin stack details).
