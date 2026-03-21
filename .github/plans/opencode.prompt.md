# Plan: opencode Integration into Dotfiles

**TL;DR**: Add opencode as a proper dotfiles package with a stow-managed config, an install script, and an interactive wizard for MCPs/agents/instructions.

---

## Phase 1: Dotfiles Package Structure

1. Create `opencode/.config/opencode/opencode.jsonc`
   - GitHub Copilot as provider (left for user to `/connect` post-install)
   - MCPs: `context7` (enabled), `github` (disabled by default, uses `{env:GITHUB_PERSONAL_ACCESS_TOKEN}`)
   - `"instructions": ["AGENTS.md"]` to load the global rules file

2. Create `opencode/.config/opencode/AGENTS.md`
   - Starter global conventions/rules file

3. _Note:_ `agents/` and `commands/` dirs are **not stowed** — they're real dirs managed dynamically by the wizard

---

## Phase 2: Install Script

4. Create `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-opencode`
   - Follows `bin-template` POSIX sh pattern, supports `install` arg
   - Arch (with yay installed, otherwise manual AUR install) → `yay -S opencode-bin`; others → `XDG_BIN_DIR=$HOME/.local/bin curl -fsSL https://opencode.ai/install | bash`
   - Prints post-install notice: _"Run `opencode` then `/connect`, select GitHub Copilot"_

---

## Phase 3: Wizard Script

5. Create `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-opencode-wizard`
   - Interactive POSIX sh menu:
     - **Add MCP** — prompts local/remote, name, command/URL, env vars → writes to `opencode.json` via `jq` (falls back to `python3 -c json`)
     - **Create Agent** — calls `opencode agent create` if installed, else creates `.md` manually in `~/.config/opencode/agents/`
     - **Edit Instructions** — opens `~/.config/opencode/AGENTS.md` in `$EDITOR`
     - **Enable/Disable MCP** — toggles `enabled` on existing entries
     - **View Config** — displays current `opencode.json`

---

## Phase 4: Wire Into Existing Setup

6. Modify `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup`
   - Add `dotfiles-opencode` to copied scripts list in `setup_directory()`
   - Add `prompt_installation "opencode" "./dotfiles-opencode"` block in `main()` (Linux only, skip Termux)

7. Modify `stowme.sh`
   - Add `opencode` to the `dotstow stow ...` package list

---

## Relevant Files

- `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/bin-template` — template reference
- `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup` — wire install in here
- `stowme.sh` — add `opencode` to package list

**New files to create:**

- `opencode/.config/opencode/opencode.jsonc`
- `opencode/.config/opencode/AGENTS.md`
- `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-opencode`
- `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-opencode-wizard`

---

## Verification

1. Run `stowme.sh` → `~/.config/opencode/opencode.jsonc` and `AGENTS.md` are symlinked
2. Run `dotfiles-opencode install` → `opencode` binary exists in PATH
3. Run `opencode --version` → confirms install
4. Run `dotfiles-opencode-wizard` → test each menu option
5. Launch `opencode` → config + MCPs load correctly

---

## Decisions

- GitHub Copilot auth is always interactive (device code) — the script can't automate it, just guides the user
- GitHub MCP is pre-configured but _disabled_ by default; wizard enables it once user sets `GITHUB_PERSONAL_ACCESS_TOKEN`
- JSON editing in wizard: `jq` → `python3` → print manual instructions
- `agents/` dir is intentionally _not stowed_ (dynamically managed by wizard/opencode CLI)
- Termux excluded from scope
- `autoupdate: true` in config — always track latest opencode version
