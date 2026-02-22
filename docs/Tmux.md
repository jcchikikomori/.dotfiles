# Tmux Configuration Guide

## Overview

Simple tmux setup with **Powerline theme** support and **TPM (Tmux Plugin Manager)** for extensibility.

## Basic Keys

| Key | Action |
|-----|--------|
| `Ctrl-b` + `\|` | Split pane vertically |
| `Ctrl-b` + `-` | Split pane horizontally |
| `Alt` + Arrow | Navigate between panes |
| `Ctrl-b` + `c` | Create new window |
| `Ctrl-b` + `x` | Close pane/window |
| `Ctrl-b` + `r` | Reload config |
| `Ctrl-b` + `I` | Install TPM plugins |
| `Ctrl-b` + `U` | Update TPM plugins |

## Powerline Theme

The status bar displays:

- **Left:** Session name and window list
- **Right:** Custom pane info, date, and time

### Customizing Powerline

After first installation, the TPM plugin creates:

```bash
~/.tmux/plugins/tmux-powerline/
```

To customize:

1. **Edit powerline config** (created after first plugin install):

   ```bash
   ~/.tmux/plugins/tmux-powerline/config.sh
   ```

2. **Available customizations:**

   - `TMUX_POWERLINE_STATUS_INTERVAL_SEC` - Refresh rate (default: 1 second)
   - Color schemes can be modified in `config.sh`
   - Custom segments can be added in `segments/` directory

3. **Reload after changes:**

   ```bash
   Ctrl-b + r
   ```

## Installation

After running `dotfiles-post-setup`:

1. **Install plugins:**

   ```bash
   Ctrl-b + I
   ```

2. **Reload tmux:**

   ```bash
   tmux kill-server
   tmux new-session
   ```

## Pane-Specific Configuration

Powerline supports per-pane customization. You can:

1. Set custom pane titles:

   ```bash
   Ctrl-b + ,   (then type new name)
   ```

2. Powerline will display active pane information in the status bar

## Adding More Plugins

Edit `~/.tmux.conf` and add plugins:

```bash
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
```

Then install with `Ctrl-b + I`.

## Troubleshooting

**Powerline not showing:**

- Check if `~/.tmux/plugins/tmux-powerline/` exists
- Run `Ctrl-b + I` to install
- Reload with `Ctrl-b + r`

**Unicode/Color issues:**

- Ensure terminal supports 256 colors: `echo $TERM`
- Set in shell: `export TERM=screen-256color`

**Need to reset:**

```bash
rm -rf ~/.tmux/plugins/tmux-powerline
# Then run Ctrl-b + I to reinstall
```
