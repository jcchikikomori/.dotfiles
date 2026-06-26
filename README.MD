# .dotfiles

A collection of configuration files and scripts to streamline setting up your favorite terminal shell across various systems.
Based from existing [repository](https://github.com/sreerajkksd/dotfiles). Forked then put optimizations & adjustments to sustain my needs, and lessen the friction on configuring, every time i'm doing the setup on my fresh installed Linux hardware.

## Features

- **Personalized Environment** - Custom `Zsh`, `Bash`, `Tmux`, `Vim`, and `VSCode` configurations tailored for development workflows
- **AI Tooling Integration** - Full `opencode` and Claude Code support with custom skills for 16+ tech stacks, MCP servers, and LLM tooling
- **Cross-Platform Support** - Works across Debian, Ubuntu, Arch Linux, Fedora, macOS, SteamOS, and WSL2
- **SteamOS Optimized** - Special handling for SteamOS 3.5+ with `pacman` keyring fixes, `yay` workarounds, and immutable filesystem support
- **Desktop Environment** - KDE Plasma 6 configuration support, `tmux` overhaul with SteamOS-inspired theme, and macOS integration
- **Development Tools** - Unified `stow` script, GNU Stow conflict resolution, `dotfiles-arch` helper with `zsh` completions
- **Language Version Managers** - Automated setup for Python (`pyenv`), Node.js (`nvm`), Ruby (`rbenv`), PHP (`phpenv`), and Java (`SDKMAN`)
- **Cloud & Storage** - S4 bucket integration for EmuDeck save data backup, `copyparty` setup for local file sharing
- **Immutable System Support** - `distrobox` and `podman` integration for immutable distributions like Bazzite and SteamOS
- **Minimal Risk** - Designed to minimize the risk of system misconfiguration with safety checks and conflict resolution

> [!TIP]
> For a complete list of all stow packages, see [docs/STOW_PACKAGES.md](docs/STOW_PACKAGES.md).

## Supported Platforms

- **Windows Subsystem for Linux (WSL version 2)** - Full support with experimental local LLM setup
- **macOS (Intel + Apple Silicon)** - Darwin implementation with symlink validation and Homebrew integration
- **Ubuntu/Debian-based distributions** - Including Debian 13 support
- **Arch Linux and its derivatives** - Garuda, Manjaro, with Chaotic-AUR and CachyOS support
- **SteamOS** - Version 3.5+ with `pacman` keyring fixes, `yay` workarounds, and `dotfiles-arch` helper
- **Immutable Linux distributions** - Bazzite, Fedora Silverblue via `distrobox` and `podman`
- **Termux (Android)** - ARM support with Python (`pyenv`) officially supported
- **Fedora/RHEL-based distributions** - Full support with python header dependencies handled

## Requirements

> [!NOTE]
>
> - ARM support is currently on the way, after supporting Termux.
> - We are using the forked version of `dotstow` to support immutable Linux distributions and Termux.

Ensure the following prerequisites are met before running the setup:

1. A 64-bit operating system.
2. The `stow` package installed on your system.
3. [dotstow](https://github.com/jcchikikomori/dotstow) installed for managing dotfiles.

### For Steam Deck or any device that runs SteamOS

Since SteamOS runs in an immutable file system, i'd recommend to use `distrobox` which is already available on the system out-of-the-box.

Then you can install `dotstow` & `stow` within the container.

Recommended images to use:

- Ubuntu 22.04 and higher
- Arch Linux (barebones)
- Fedora 38 and higher

More information regarding [virtualization & managing containers](docs/Virtualization.md) here.

### For any Immutable distros

Same as Steam Deck's SteamOS, you needed to ensure that you have `distrobox` & `podman` installed either out-of-the-box or manually which is acceptable in some by putting layers on top of the base system (best example is Fedora Silverblue & Bazzite).

## Installation

### Setup Instructions

Clone this repository to your system by executing the following...

```bash
git clone https://github.com/jcchikikomori/.dotfiles.git $HOME/.dotfiles
cd $HOME/.dotfiles
git submodule update --init --recursive
```

> [!WARNING]
> Do not install this on somewhere else! Only in `$HOME/.dotfiles`.
>
> **Important:** If you skip `git submodule update --init --recursive`, stowing will fail for packages that depend on submodules (e.g., `opencode`).

Execute `start.sh` to get started.

The script will:

- Detect your operating system (e.g., Debian-based, Arch-based, RHEL-based).
- Apply the appropriate configurations and workarounds.
- Execute platform-specific setup scripts.

Then follow any additional prompts during the setup process.

### Stowing

Execute `stowme.sh` to finally symlink the files properly.
Then reboot your machine, and let the magic happen!

## Documentation

For detailed guides, usage reminders, workarounds, and additional documentation, please refer to the [`docs/`](docs/) directory.

### Quick Links

- [Stow Packages List](docs/STOW_PACKAGES.md)
- [Git Cheatsheet](docs/GitCheatsheet.md)
- [Stow Conflicts Guide](docs/STOW_CONFLICTS.md)
- [Virtualization & Containers](docs/Virtualization.md)
- [OpenCode Agent System](linux/opencode/README.md)
- [Claude Code Setup](linux/claude/README.md)

## Disclaimer & Legal Notices

Please refer to this [article here](DISCLAIMER.md).

Please refer to the [license](LICENSE) for any related to distributing the software or using it.
