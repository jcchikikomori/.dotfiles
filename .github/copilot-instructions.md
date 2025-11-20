# AI Coding Agent Instructions for .dotfiles

## Project Overview

This is a cross-platform dotfiles management system that automates shell and development environment setup across multiple Linux distributions (Debian/Ubuntu, Arch, RHEL/Fedora, SteamOS). It uses **GNU Stow** via the [dotstow](https://github.com/jcchikikomori/dotstow) wrapper to symlink configuration files from `linux/*/` directories to `$HOME`.

**Key Architecture:**
- **Entry point:** `start.sh` - detects OS, runs distro-specific `{distro}/setup.sh`, then `dotfiles-post-setup`
- **Symlinking:** Each `{distro}/stowme.sh` calls `dotstow stow` with consistent package list
- **Post-setup tools:** Shell scripts in `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/` install additional tools (pyenv, nvm, rbenv, sdkman, vim plugins, etc.)
- **Dotfile packages:** `linux/{zsh,bash,git,tmux,vim,vscode,alacritty,starship}/` contain actual config files

## Critical Setup Workflow

**Fresh installation must run in this order:**
1. Clone to `$HOME/.dotfiles` (hardcoded path - DO NOT change)
2. `./start.sh` - OS detection, package installation, calls `dotfiles-post-setup`
3. `./{distro}/stowme.sh` - symlinks configs via dotstow
4. Reboot to activate shell changes

**Environment variables set by `start.sh`:**
- `DOTFILES_PATH` → saved to `.currentdir`
- `DOTFILES_USERNAME` → saved to `.currentuser`
- `DETECTED_DISTRO` → saved to `$HOME/.dotfiles-distro` (values: ubuntu, debian, archbtw, arch, steamos, rhel, termux)

## Distro-Specific Patterns

### Arch Linux "Barebones" Special Case
- Detected as `archbtw` when `NAME == *"Arch Linux"*`
- Requires `arch/init.sh` to run first (sets locale, installs base-devel, yay AUR helper, Chaotic-AUR)
- In CI: runs `arch/init.sh` automatically
- On user systems: prompts for sudo to run `arch/init.sh`

### SteamOS/Immutable Systems
- Recommends **distrobox** (immutable filesystem workaround)
- See `docs/Virtualization.md` for podman/docker rootless setup patterns

### Termux (Android Terminal Emulator)
- **No sudo:** All commands run as unprivileged user in `/data/data/com.termux/`
- **Package manager:** `pkg` (wrapper around apt with Termux-specific repos)
- **Mirror setup critical:** Must ensure `pkg` mirrors are working before setup
- **No systemd:** Cannot use systemctl or system-level services
- **Storage access:** Use `termux-setup-storage` to access `/sdcard`
- **PATH differences:** Uses `$PREFIX` (typically `/data/data/com.termux/files/usr`)
- **Key constraints:**
  - Cannot write to `/usr`, `/bin`, `/etc` (use `$PREFIX` equivalents)
  - No support for glibc-dependent binaries (uses Bionic libc)
  - Limited support for system calls (Android kernel restrictions)

### Package Managers by Distro
- **Arch:** `pacman` + `yay` (AUR helper installed by `arch/init.sh`)
- **Debian/Ubuntu:** `apt`/`apt-get`
- **RHEL/Fedora:** `dnf`
- **SteamOS:** Uses `pacman` but requires `steamos-readonly disable` for system changes
- **Termux:** `pkg` (apt-based, but with Termux-specific packages and paths)

## Shell Configuration Architecture

**Primary shell:** Zsh with oh-my-zsh framework
**Fallback:** Bash (generated from `/etc/skel/.bashrc` by `start.sh`)

**Zsh plugin stack (`linux/zsh/.zshrc`):**
- oh-my-zsh (installed by `dotfiles-post-setup`)
- Antigen (downloaded to `$HOME/antigen.zsh`, loaded from `~/.antigenrc`)
- Starship prompt (binary in `~/.local/bin`)
- Custom plugins in `$ZSH_CUSTOM_DIR/plugins/`: git-flow-completion, zsh-autosuggestions, zsh-syntax-highlighting, fast-syntax-highlighting, zsh-autocomplete, zsh-histdb

**PATH configuration:**
`$HOME/.local/bin/org.jcchikikomori.dotfiles/bin` is added to PATH in `.zshrc:126` - all custom scripts use this namespace.

## Scripting Conventions

**All scripts use POSIX `#!/bin/sh`** (not bash-specific) for maximum compatibility.

**Naming convention:** `dotfiles-{purpose}` for all utilities in `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/`

**Common patterns:**
```bash
# Interactive prompts (skip in CI/unattended mode)
if [ -n "${SKIP_INSTALL_PROGLANG}" ]; then
  echo "Unattended mode: Skipping..."
  return
fi

# Git clone with ignore-existing
git clone -q --depth 1 https://... ~/.target || true

# Symlink safety
ln -s -f source target  # Force overwrite existing
```

**Template for new scripts:** `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/bin-template`

## Version Manager Installation Pattern

Programming language version managers are **optionally** installed by `dotfiles-post-setup` with interactive prompts:

- **Python:** `dotfiles-python` → pyenv + latest Python 3
- **Ruby:** `dotfiles-ruby` → rbenv (marked UNSTABLE in README)
- **Node.js:** `dotfiles-nodejs` → nvm
- **PHP:** `dotfiles-php` → phpenv-git (marked UNTESTED)
- **Java:** `dotfiles-java-sdkman` → SDKMAN

**Installation scripts** (in `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/`) accept `install` argument:
```bash
./dotfiles-python install
```

**Modifying version manager scripts safely:**
1. **Never rename script files** - names are referenced in `dotfiles-post-setup` and CI workflows
2. Test changes in CI by adding temporary step to `ci-unit-test.yml`
3. Common modification points:
   - Version detection logic (e.g., changing default Python version)
   - Installation flags/options passed to version managers
   - Environment variable exports
4. Keep interactive prompt logic intact - check for `SKIP_INSTALL_PROGLANG`
5. Maintain `install` argument support for CI/unattended mode

## Stow Package Consistency

**All `stowme.sh` files must stow the same package list:**
```bash
dotstow stow bash zsh git antigen tmux tmuxp vim vscode dxvk systems flatpak alacritty wireplumber flags lindbergh starship
```

**Packages map to directories:**
- `bash` → `linux/bash/`
- `zsh` → `linux/zsh/`
- `systems` → `linux/systems/` (contains `.local/bin/` scripts)
- etc.

**Before stowing:** `dotfiles-cleanup` and `dotfiles-ssh` scripts run to prepare environment.

## CI/CD Integration

**GitHub Actions workflows** (`.github/workflows/`):
- `ci-arch.yml` - Tests Manjaro container
- `ci-lemp.yml` - Tests Ubuntu LEMP stack setup
- `ci-unit-test.yml` - General integration tests (ubuntu, arch, fedora jobs)

**CI-specific environment variables:**
- `SKIP_SETTING_USER=true` - Skip user creation prompts
- `SKIP_INSTALL_PROGLANG=false` - Enable automated language manager installation
- `CI=true` - Triggers special behavior in `start.sh` (e.g., auto-sudo for arch/init.sh)

**Common CI workflow pattern:**
```yaml
steps:
  - name: Setup some directories
    run: |
      mkdir -p $HOME/.dotfiles
      mkdir -p $HOME/.local/state/dotstow
      mkdir -p $HOME/.local/bin/org.jcchikikomori.dotfiles/bin
      cp -r $PWD/* $HOME/.dotfiles/
  - name: Getting Started
    run: ./start.sh
  - name: Simulate Stowing
    run: sh {distro}/stowme.sh
```

**Testing individual post-setup scripts in CI:**
```yaml
- name: Execute post-setup (python)
  run: ./linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-python install
```

**Artifact collection pattern (`ci-unit-test.yml`):**
- Generates file listings from `$HOME` directory
- Uploads logs to `/tmp/org.jcchikikomori.dotfiles/` as artifacts
- Uses `if: always()` to ensure stowing/artifact steps run even on failure

## Critical Paths and Files

**Hardcoded locations (do not change):**
- Dotfiles repo: `$HOME/.dotfiles`
- Scripts: `$HOME/.local/bin/org.jcchikikomori.dotfiles/bin/`
- Dotstow state: `$HOME/.local/state/dotstow/dotfiles` → symlinked to `$HOME/.dotfiles`

**Generated at runtime:**
- `$HOME/.bashrc` - Copied from `/etc/skel/.bashrc` by `start.sh`
- `$HOME/.dotfiles-distro` - Contains detected distro name
- `$HOME/.currentdir` - Contains `$DOTFILES_PATH`
- `$HOME/.currentuser` - Contains `$DOTFILES_USERNAME`

## Special Features & Easter Eggs

- **Lindbergh arcade games:** `lindbergh-id5`, `lindbergh-outrun2` scripts run SEGA Lindbergh arcade games via Wine/Proton
- **Nerd Fonts:** `dotfiles-nerf` installs JetBrainsMono and FiraCode fonts
- **Alacritty themes:** Cloned from `alacritty/alacritty-theme` to `~/.config/alacritty/themes`
- **Tmux:** Uses gpakosz/.tmux config framework with TPM (Tmux Plugin Manager)

## Editing Guidelines

**When modifying distro setup scripts:**
1. Test on actual distro (use GitHub Actions for validation)
2. Keep package names minimal - post-setup tools install extras
3. Maintain `DETECTED_DISTRO` consistency in `start.sh` case statement

**When adding new dotfile configs:**
1. Create directory under `linux/{package-name}/`
2. Add `{package-name}` to ALL `stowme.sh` files
3. Test symlink paths match intended `$HOME` structure

**When creating new utility scripts:**
1. Use `bin-template` as starting point
2. Follow `dotfiles-{verb}` naming (e.g., `dotfiles-install-foo`)
3. Place in `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/`
4. Use POSIX sh, not bash-specific syntax
5. **Never refactor/rename existing script files without explicit approval**

## Termux-Specific Development Notes

**Critical pre-setup requirements:**
1. Verify `pkg` mirrors are accessible and working (`termux-change-repo`)
2. Run `pkg update && pkg upgrade` before dotfiles installation
3. Check `$PREFIX` is correctly set (should be `/data/data/com.termux/files/usr`)

**Termux detection mechanism:**
- Uses `$PREFIX` environment variable containing "com.termux" for detection
- Runs before `/etc/os-release` check in `start.sh` (Termux doesn't have standard Linux paths)
- Sets `DETECTED_DISTRO=termux`

**Programming language support:**
- **Only Python (pyenv) is officially supported** on Termux/ARM
- Other language managers (Ruby, PHP, Java, NodeJS) have compatibility issues with Android userspace
- `dotfiles-post-setup` only prompts for Python installation on Termux
- Users must manually install other languages if needed

**Common Termux gotchas:**
- No `/etc/skel/.bashrc` - fallback handled in `generate_bashrc()` function
- `stow` must be installed via `pkg install stow`
- Git repos should use HTTPS (SSH requires additional Termux setup)
- Some build tools require `pkg install binutils` for compilation
- `termux-reload-settings` may fail with app_process errors (gracefully handled with `2>/dev/null || true`)

**Testing Termux changes:**
- Cannot use real Termux in GitHub Actions (no Android runners)
- `ci-termux.yml` simulates Termux by setting `PREFIX=/data/data/com.termux/files/usr`
- Full validation requires manual testing on Termux app or specialized Docker container
- Validate `pkg` package availability before adding to `termux/setup.sh`
