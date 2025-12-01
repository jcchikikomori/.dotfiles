# .dotfiles

A collection of configuration files and scripts to streamline setting up your favorite terminal shell across various systems.
Based from existing [repository](https://github.com/sreerajkksd/dotfiles). Forked then put optimizations & adjustments to sustain my needs, and lessen the friction on configuring, every time i'm doing the setup on my fresh installed Linux hardware.

## Features

- Personalized features.
- Customizations alongside the forked files.
- Includes specific patches and workarounds for various platforms.
- Designed to minimize the risk of system misconfiguration.
- Added configurations that i personally use.

### Added packages (post-setup)

|Package    |Description                 |Remarks   |
|-----------|----------------------------|----------|
|homebrew   |Linuxbrew                   |Not working with Termux at this moment.|
|pre-commit |Adds validation/features on git before committing||
|sdkman     |Java JDK/JRE manager        |          |
|vim        |Duh?                        |          |
|pyenv      |Python version manager      |Not working with Termux at this moment.|
|phpenv     |PHP version manager         |Untested  |
|rbenv      |Ruby version manager        |Untested  |

## Supported Platforms

- Windows Subsystem for Linux (WSL version 2)
- Ubuntu/Debian-based distributions
- Arch Linux and its derivatives (e.g., Garuda, Manjaro, SteamOS)
- Immutable Linux distributions (e.g., Bazzite, SteamOS, etc.)
- Termux (Untested)
- Fedora/RHEL-based distributions

## Installation

The setup process is now fully automated using the `start.sh` script. This script detects your operating system and applies the appropriate configurations and workarounds.

### Requirements

> [!NOTE]
>
> - ARM support is currently on the way, after supporting Termux.
> - We are using the forked version of dotstow to support immutable Linux distributions and Termux.

Ensure the following prerequisites are met before running the setup:

1. A 64-bit operating system.
2. The `stow` package installed on your system.
3. [dotstow](https://github.com/jcchikikomori/dotstow) installed for managing dotfiles.

#### For Steam Deck or any device that runs SteamOS

Since SteamOS runs in an immutable file system, i'd recommend to use `distrobox` which is already available on the system out-of-the-box.

Then you can install `dotstow` & `stow` within the container.

Recommended images to use:

- Ubuntu 22.04 and higher
- Arch Linux (barebones)
- Fedora 38 and higher

More information regarding [virtualization & managing containers](docs/Virtualization.md) here.

#### For any Immutable distros

Same as Steam Deck's SteamOS, you needed to ensure that you have `distrobox` & `podman` installed either out-of-the-box or manually which is acceptable in some by putting layers on top of the base system (best example is Fedora Silverblue & Bazzite).

### Setup Instructions

Clone this repository to your system by executing the following...

```bash
git clone https://github.com/jcchikikomori/.dotfiles.git $HOME/.dotfiles
cd $HOME/.dotfiles
```

> [!WARNING]
> Do not install this on somewhere else! Only in `$HOME/.dotfiles`.

## Setup

Execute `start.sh` to get started.

The script will:
Detect your operating system (e.g., Debian-based, Arch-based, RHEL-based).
Apply the appropriate configurations and workarounds.
Execute platform-specific setup scripts.

Then follow any additional prompts during the setup process.

### Stowing

Execute `stowme.sh` to finally symlink the files properly.
Then reboot your machine, and let the magic happen!

## Post-Setup

After running the setup, the dotfiles-post-setup script will handle additional configurations, including:

Installing essential tools like fzf, fasd, and oh-my-zsh.
Setting up programming environments (e.g., Python, Ruby, Node.js, PHP).
Configuring vim with plugins and tmux with TPM.
Installing the Starship prompt and Antigen for Zsh.
Refer to the `dotfiles-post-setup script` for more details.

## CI Integration

This repository includes a CI workflow; For example: Ubuntu, located in `.github/ci-ubuntu.yml`. The workflow automates the following tasks

Initializes essential dependencies.
Executes the `start.sh` script.
Adds a user and simulates stowing dotfiles.

## Workarounds

### Arch Linux Barebones

For Arch Linux, please follow the [instructions here](arch/README.MD).

## Disclaimer & Legal Notices

Please refer to this [article here](DISCLAIMER.md).

Please refer to the [license](LICENSE) for any related to distributing the software or using it.
