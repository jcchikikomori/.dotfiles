# Tmux Configuration Guide

## Overview

Custom tmux setup with **SteamOS theme** styling, **TPM** (Tmux Plugin Manager), and **Gitmux** integration for git status display in the status bar.

## Plugins

Managed via TPM (`~/.tmux/plugins/tpm`):

- **tmux-sensible** - Sensible defaults
- **tmux-resurrect** - Session persistence across restarts
- **tmux-prefix-highlight** - Highlights when prefix is active
- **tmux-mem-cpu-load** - System resource monitor
- **tmux-acpi** - Battery/power status
- **tmux-notify** - Notifications for long-running commands
- **tmux-autoreload** - Auto-reload config on changes
- **tmux-powerline** - Renders the status bar (see below); config lives in `~/.config/tmux-powerline/`

## Basic Keys

| Key | Action |
| ----- | -------- |
| `Ctrl-b` + `\|` | Split pane vertically |
| `Ctrl-b` + `-` | Split pane horizontally |
| `Alt` + Arrow | Navigate between panes |
| `Ctrl-b` + `c` | Create new window |
| `Ctrl-b` + `x` | Close pane/window |
| `Ctrl-b` + `r` | Reload config |

## Status Bar - SteamOS Theme

Rendered by the `erikw/tmux-powerline` TPM plugin as powerline segments (arrow-separated colored blocks), configured in `linux/tmux/.config/tmux-powerline/` (stowed to `~/.config/tmux-powerline/`):

- **Left:** Session name (`tmux_session_info`, cyan) + mem-cpu-load (`tmux_mem_cpu_load`)
- **Center:** Window list (centered)
- **Right:** Prefix-highlight indicator + git status (`git_status` segment, wraps gitmux) + Power/Battery (`power_status` segment, wraps tmux-acpi) + clock (`date_time` segment)

Custom segments live in `linux/tmux/.config/tmux-powerline/segments/`; the segment layout, colors, and window-tab formatting are set in `linux/tmux/.config/tmux-powerline/config.sh`. tmux-powerline needs a Powerline-patched or Nerd Font in the terminal emulator to render the arrow separators correctly (see `dotfiles-nerf`).

### Color Scheme

- **Background:** `#0E1419` (SteamOS dark)
- **Highlight:** `#00BFFF` (Cyan)
- **Pane borders:** Dark background with cyan active border

## Installation

### Gitmux Setup

Gitmux is optional but recommended for git status display. Install it:

```bash
~/.dotfiles/linux/tmux/.tmux/bin/gitmux.sh
```

Or manually:

```bash
brew install gitmux      # macOS
apt install gitmux       # Debian/Ubuntu
dnf install gitmux       # RHEL/Fedora
pacman -S gitmux        # Arch Linux
pkg install gitmux      # Termux
```

If gitmux is not installed, the status bar will fall back to showing just the time.

### Tmux Config

The main config file is at `~/.tmux.conf`. After changes:

```bash
# Reload configuration
Ctrl-b + r

# Or reload from terminal
tmux source ~/.tmux.conf
```

## Troubleshooting

**Gitmux not showing in status bar:**

- Ensure gitmux is installed: `command -v gitmux`
- Check the config file exists: `~/.gitmux.conf`
- The status bar will fall back to time-only if gitmux is missing (no errors)

**Color issues:**

- Ensure terminal supports 256 colors: `echo $TERM`
- Set in shell if needed: `export TERM=screen-256color`

**Reset configuration:**

```bash
# Remove tmux session
tmux kill-server

# Remove config and restore
rm ~/.tmux.conf
# Re-stow or copy from dotfiles
```

## Auto-Start Behavior

Tmux auto-start is controlled by `TMUX_DISABLE_AT_BOOT`:

- Set to `0` (enabled) only if both `tmux` and `brew` are installed
- Set to `1` (disabled) otherwise

Configured in `~/.profile` and `~/.bashrc.d/00-env`.
