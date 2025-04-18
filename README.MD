# .dotfiles

A collection of configuration files and scripts to streamline setting up your favorite terminal shell across various systems.

Forked from another [repository](https://github.com/sreerajkksd/dotfiles), with additional customizations and improvements.

## Features

- Programmer-focused dotfiles.
- Personal customizations alongside the forked files.
- Includes specific patches and workarounds for various platforms.
- Designed to minimize the risk of system misconfiguration.

## Supported Platforms

- Windows Subsystem for Linux (WSL)
- Ubuntu/Debian-based distributions
- Arch Linux and its derivatives (e.g., Garuda, Manjaro)
- Fedora/RHEL-based distributions
- Android Subsystems for Linux (e.g., Andronix)

## Installation

The setup process is now fully automated using the `start.sh` script. This script detects your operating system and applies the appropriate configurations and workarounds.

### Requirements

Ensure the following prerequisites are met before running the setup:

1. A 64-bit operating system.
2. The `stow` package installed on your system.
3. [dotstow](https://github.com/jcchikikomori/dotstow) installed for managing dotfiles.

### Setup Instructions

Clone this repository to your system by executing the following...
```bash
git clone https://github.com/jcchikikomori/.dotfiles.git $HOME/.dotfiles
cd $HOME/.dotfiles
```

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
Executes the start.sh script.
Adds a user and simulates stowing dotfiles.

## Workarounds

### Arch Linux

For Arch Linux, please follow the [instructions here](arch/README.MD).

## Disclaimer & Legal Notices

Please refer to this [article here](DISCLAIMER.md).
