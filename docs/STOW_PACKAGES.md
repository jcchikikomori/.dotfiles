# Stow Packages

This document lists all stow packages managed by this dotfiles repository.

## All Packages

| Package | Description | Platforms |
|---------|-------------|-----------|
| `alacritty` | GPU-accelerated terminal emulator | All |
| `antigen` | Zsh plugin manager | All |
| `bash` | Bash shell configuration | Linux |
| `dxvk` | D3D9/D3D10/D3D11 to Vulkan translation layer | Linux, macOS |
| `flags` | CLI flags/arguments configuration | All |
| `flatpak` | Flatpak configuration | Linux |
| `git` | Git configuration | All |
| `lindbergh` | Lindbergh arcade emulator (Sega Model 2) | Linux |
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

All packages listed above except `bash`, `dxvk`, `flatpak`, `lindbergh`, `wireplumber`.

### macOS

| Package | Description |
|---------|-------------|
| `zsh` | Zsh shell configuration |
| `git` | Git configuration |
| `antigen` | Zsh plugin manager |
| `tmux` | Terminal multiplexer |
| `tmuxp` | Tmux session manager |
| `vim` | Vim text editor |
| `vscode` | VS Code configuration |
| `dxvk` | D3D9/D3D10/D3D11 to Vulkan translation layer |
| `systems` | System-specific configs |
| `python` | Python environment setup |
| `flatpak` | Flatpak configuration |
| `alacritty` | GPU-accelerated terminal emulator |
| `wireplumber` | PipeWire session manager |
| `flags` | CLI flags/arguments configuration |
| `lindbergh` | Lindbergh arcade emulator (Sega Model 2) |
| `supermodel` | Sega Model 3 emulator |
| `starship` | Cross-shell prompt |
| `opencode` | OpenCode agent configuration |

## Package Details

### Shell Configurations

- **bash** - Bash shell configuration with aliases and functions
- **zsh** - Zsh shell configuration with oh-my-zsh and antigen
- **antigen** - Zsh plugin manager bundle configuration

### Development Tools

- **git** - Git configuration with aliases and customizations
- **vim** - Vim configuration with plugins
- **vscode** - VS Code settings and extensions
- **python** - Python environment setup (pyenv, virtualenv)

### Terminal Tools

- **tmux** - Terminal multiplexer configuration
- **tmuxp** - Tmux session manager configuration
- **alacritty** - GPU-accelerated terminal emulator config
- **starship** - Cross-shell prompt configuration

### Gaming/Emulation

- **supermodel** - Sega Model 3 emulator configuration
- **lindbergh** - Lindbergh arcade emulator (Sega Model 2) configuration

### Wine/DXVK

- **dxvk** - D3D9/D3D10/D3D11 to Vulkan translation layer for macOS gaming

### System Integration

- **systems** - System-specific configs including:
  - Systemd user units
  - EmuDeck sync tools
  - EmulationStation configuration
  - Other system-level configurations

### Flatpak/Wireplumber

- **flatpak** - Flatpak configuration
- **wireplumber** - PipeWire session manager configuration

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
