# dotfiles

To ease setting up your favorite Terminal shell.. on various systems

Forked from another [repository](https://github.com/sreerajkksd/dotfiles).

## Features

- Programmer-focused dotfiles
- My personal chosen setups, beside the forked files
- Included specific patches/workarounds
- Aim to prevent messing up the system

## Supported Platforms

- Windows Subsystem for Linux
- Ubuntu/Debian
- Arch Linux
- Fedora

## Installation

Go to the environment (folder) then execute the `setup.sh` to began installing & setting up necessary dependencies.

### Requirements

Packages below must be installed on your system.

1. A 64-bit operating system (for specific OS, please look [this section](#choosing-environment))
2. Package called `stow`
3. Package called [dotstow](https://github.com/jcchikikomori/dotstow)

### Choosing Environment

If you are using Windows Subsystem for Linux, please refer to the directory that starts with `wsl-`, due to different method of booting the Linux subsystem in Windows 10 and higher, including workarounds such as X server, Domain Resolutions, `$PATH` resolutions, etc.

- Windows Subsystem for Linux `=>` `wsl-*`
- Ubuntu `=>` `ubuntu`
- Arch Linux `=>` `arch`
- Garuda (Arch-based system) `=>` `arch`
- Fedora `=>` `rhel`
- Any Android Subsystem for Linux (Andronix, etc.) `=>` `andronix`

## Setup

Execute `stowme.sh` on specific environment you've choose.

For Arch Linux, please follow the [instructions here](arch/README.MD).

### Custom profile

Just create `.dotprofile` on home directory,
then you can do anything EXCEPT `tmux`, `byobu`, & `tmuxp`!!

```shell
touch ~/.dotprofile
```
