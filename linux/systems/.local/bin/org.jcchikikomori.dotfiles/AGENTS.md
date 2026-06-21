# Agent Notes: dotfiles-bin

This directory contains user-local utility scripts for the dotfiles setup.

## `bin/dotfiles-arch`

Arch Linux helper for setting up AUR repositories, repairing the pacman keyring, and installing AUR/edge packages on any Arch-based system.

### Commands

```text
setup / all              Full chain: fix-keyring → setup-repositories → install-yay → install-packages
fix-keyring              Initialize or repair the pacman keyring
setup-repositories       Add Chaotic AUR and CachyOS repositories
install-yay              Build and install yay-bin from AUR
install-packages         Install mandatory packages (podman-docker, xsel, ncdu, rclone)
install-packages-edge    Install optional edge packages (dmemcg-booster, kcgroups, plasma-foreground-booster)
help                     Show usage
```

### Options

- `-o`, `--optional` — When used with `setup`, also runs `install-packages-edge`.
- Options may appear before or after the command, e.g. `dotfiles-arch --optional setup` or `dotfiles-arch setup -o`.

### install-packages

- `install-packages` should only include essential or working or stable packages or any that are available on reputable sources.
- `install-packages-edge` should only include experimental packages that are not suitable to all systems, and this is mostly for power users.

#### Adding AUR package into install-packages

- For any AUR-related requests, you must search online regarding the safety implications, since a specific package from AUR could be orphaned or infected with malwares, backdoors, etc., so make a research and then report back to the user.

### Examples

```sh
# Full setup without edge packages
dotfiles-arch setup

# Full setup including edge packages
dotfiles-arch setup --optional

# Run individual steps
dotfiles-arch fix-keyring
dotfiles-arch setup-repositories
dotfiles-arch install-yay
dotfiles-arch install-packages
```

### Notes for agents

- All steps are idempotent: they check whether repositories/packages already exist before acting.
- This script is **not** invoked by `start.sh`; it is intended to be run manually when AUR setup is needed.
- SteamOS-specific handling (e.g. `steamos-readonly`, `holo` keyring) is kept in `dotfiles-steamdeck` and `steamos/setup.sh`, not here.
- `arch/setup.sh` has been stripped of AUR-related logic; use `dotfiles-arch` for that instead.
- On SteamOS, any command that modifies the system checks `steamos-readonly status` first. If the rootfs is read-only, the script exits with instructions to run `dotfiles-steamdeck writeable` or `sudo steamos-readonly disable`.
- `install-yay` installs `debugedit` and `fakeroot` if missing, since SteamOS 3.8.10+ removed them but `makepkg` requires them to build `yay-bin`.
