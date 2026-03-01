# Tmux Configuration Guide

## Overview

Simple tmux setup with **SteamOS theme** styling and **Gitmux** integration for git status display in the status bar.

## Basic Keys

| Key | Action |
|-----|--------|
| `Ctrl-b` + `\|` | Split pane vertically |
| `Ctrl-b` + `-` | Split pane horizontally |
| `Alt` + Arrow | Navigate between panes |
| `Ctrl-b` + `c` | Create new window |
| `Ctrl-b` + `x` | Close pane/window |
| `Ctrl-b` + `r` | Reload config |

## Status Bar - SteamOS Theme

The status bar displays:

- **Left:** Session name (cyan highlight on dark background)
- **Right:** Git status (via gitmux) + current time

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
