# .dotfiles

A collection of configuration files and scripts to streamline setting up your favorite terminal shell across various systems.
Based from existing [repository](https://github.com/sreerajkksd/dotfiles). Forked then put optimizations & adjustments to sustain my needs, and lessen the friction on configuring, every time i'm doing the setup on my fresh installed Linux hardware.

## Features

- Personalized features.
- Customizations alongside the forked files.
- Includes specific patches and workarounds for various platforms.
- Designed to minimize the risk of system misconfiguration.
- Added configurations that i personally use.

> [!TIP]
> For a complete list of all stow packages, see [docs/STOW_PACKAGES.md](docs/STOW_PACKAGES.md).

## Supported Platforms

- Windows Subsystem for Linux (WSL version 2)
- macOS (Intel + Apple Silicon)
- Ubuntu/Debian-based distributions
- Arch Linux and its derivatives (e.g., Garuda, Manjaro, SteamOS)
- Immutable Linux distributions (e.g., Bazzite, SteamOS, etc.)
- Termux (Untested)
- Fedora/RHEL-based distributions

## Requirements

> [!NOTE]
>
> - ARM support is currently on the way, after supporting Termux.
> - We are using the forked version of dotstow to support immutable Linux distributions and Termux.

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
```

> [!WARNING]
> Do not install this on somewhere else! Only in `$HOME/.dotfiles`.

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
- [OpenCode Agent System](.opencode/README.md)

## Disclaimer & Legal Notices

Please refer to this [article here](DISCLAIMER.md).

Please refer to the [license](LICENSE) for any related to distributing the software or using it.
