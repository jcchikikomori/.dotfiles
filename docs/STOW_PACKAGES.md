# Stow Packages

This document lists all stow packages managed by this dotfiles repository.

## All Packages

| Package | Description | Platforms |
|---------|-------------|-----------|
| `alacritty` | GPU-accelerated terminal emulator | Linux, macOS (limited) |
| `antigen` | Zsh plugin manager | All |
| `bash` | Bash shell configuration | Linux |
| `dxvk` | D3D8/D3D9/D3D10/D3D11 to Vulkan translation layer | Linux (with Wine) |
| `flags` | CLI flags/arguments configuration | All |
| `flatpak` | Flatpak configuration | Linux |
| `git` | Git configuration | All |
| `lindbergh` | Sega Lindbergh arcade emulator loader | Linux |
| `opencode` | OpenCode agent configuration | All |
| `python` | Python environment setup | All |
| `starship` | Cross-shell prompt | All |
| `supermodel` | Sega Model 3 emulator | All |
| `systems` | System-specific configs (systemd, emulators, etc.) | Linux |
| `tmux` | Terminal multiplexer | All |
| `tmuxp` | Tmux session manager | All |
| `vim` | Vim text editor | All |
| `vscode` | VS Code configuration | All |
| `wireplumber` | PipeWire session manager | Linux |
| `zsh` | Zsh shell configuration | All |

## Platform-Specific Packages

### Linux (Debian, Ubuntu, Arch, SteamOS, RHEL, etc.)

All packages listed above except `bash`.

### macOS

| Package | Description | Notes |
|---------|-------------|-------|
| `zsh` | Zsh shell configuration | Default shell on macOS |
| `git` | Git configuration | Pre-installed via Xcode |
| `antigen` | Zsh plugin manager | |
| `tmux` | Terminal multiplexer | |
| `tmuxp` | Tmux session manager | |
| `vim` | Vim text editor | |
| `vscode` | VS Code configuration | |
| `systems` | System-specific configs | Limited (no systemd) |
| `python` | Python environment setup | |
| `alacritty` | GPU-accelerated terminal emulator | Limited/deprecated |
| `flags` | CLI flags/arguments configuration | |
| `supermodel` | Sega Model 3 emulator | |
| `starship` | Cross-shell prompt | |
| `opencode` | OpenCode agent configuration | |

**Note:** `flatpak`, `wireplumber`, `lindbergh`, and `dxvk` are not available on macOS.

## Package Details

### Shell Configurations

- **bash** - Bash shell configuration with aliases and functions
- **zsh** - Zsh shell configuration with oh-my-zsh and antigen
- **antigen** - Zsh plugin manager bundle configuration (inspired by Vundle for Vim)

### Development Tools

- **git** - Git configuration with aliases and customizations
- **vim** - Vim configuration with plugins
- **vscode** - VS Code settings and extensions
- **python** - Python environment setup (pyenv, virtualenv)

### Terminal Tools

- **tmux** - Terminal multiplexer configuration
- **tmuxp** - Tmux session manager configuration (save/load tmux sessions via YAML/JSON)
- **alacritty** - GPU-accelerated terminal emulator config
- **starship** - Cross-shell prompt configuration (written in Rust)

### Gaming/Emulation

- **supermodel** - Sega Model 3 emulator (arcade platform 1996-1999)
- **lindbergh** - Sega Lindbergh arcade emulator loader (NOT Model 2; games like House of the Dead 4, Outrun 2)

### Wine/DXVK

- **dxvk** - D3D8/D3D9/D3D10/D3D11 to Vulkan translation layer for running Windows games on Linux with Wine

### System Integration

- **systems** - System-specific configs including:
  - Systemd user units (emudeck-sync, copyparty, etc.)
  - EmuDeck sync tools
  - EmulationStation configuration
  - Other system-level configurations

### Flatpak/Wireplumber

- **flatpak** - Flatpak package manager configuration
- **wireplumber** - PipeWire session and policy manager configuration

### CLI Tools

- **flags** - CLI flags/arguments configuration for various tools
- **opencode** - OpenCode agent configuration

## Managing Packages

To add or remove packages, edit the `STOW_PACKAGES` variable in `stowme.sh`:

```sh
# Linux
STOW_PACKAGES="bash zsh git antigen tmux tmuxp vim vscode dxvk systems python flatpak alacritty wireplumber flags lindbergh supermodel starship opencode"

# macOS
STOW_PACKAGES="zsh git antigen tmux tmuxp vim vscode systems python alacritty flags supermodel starship opencode"
```

After editing, run `stowme.sh` to apply changes.
