# dotfiles

To ease setting up your favorite Terminal shell.. on various systems

Forked from another [repository](https://github.com/sreerajkksd/dotfiles).\
And [dotstow](https://github.com/clayrisser/dotstow) must be installed on your system.

## Features

- Programmer-focused dotfiles
- My personal chosen setups, beside the forked files
- Included specific patches/workarounds
- Aim to prevent messing up the system

## Supported Platforms

- Windows Subsystem for Linux
- Ubuntu/Debian (WIP)
- Arch Linux (WIP)
- RHEL Linux
- Garuda

## Installation

Go to the environment (folder) then execute the `setup.sh` to began installing & setting up necessary dependencies.

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
