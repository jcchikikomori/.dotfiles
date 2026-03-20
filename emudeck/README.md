# EmuDeck MEGA S4 Cloud Sync

Cloud sync support for EmuDeck using **rclone** and **MEGA S4** (S3-compatible storage). This enables seamless backup and restore of game saves, save states, and configurations across devices for multiple emulators.

## Overview

This suite provides automated cloud backup and restoration of game data for multiple EmuDeck emulators using MEGA S4 storage.

### Supported Emulators

- **RetroArch** — Saves, states, core configs, NVRAM, and cheats
- **PCSX2** — PlayStation 2 memory cards and save states
- **Flycast** — Dreamcast/NAOMI/Atomiswave saves and configuration

### What Gets Synced?

#### RetroArch
- **Saves**: Game save files
- **Save States**: Emulator save states
- **Config Overrides**: Core-specific configs, shader presets, controller remaps
- **NVRAM**: Service menu configurations
- **Cheats**: Cheat files

#### PCSX2
- **Memory Cards**: PS2 game saves
- **Save States**: Emulator save states

#### Flycast
- **Saves**: VMU save files and game data
- **Save States**: Emulator save states
- **Configuration**: emu.cfg, controller mappings
- **Data**: Custom textures and additional data

## Prerequisites

### 1. Install rclone

rclone is automatically installed when you run the main dotfiles setup:
```bash
./start.sh
```

Or install manually:
```bash
# Ubuntu/Debian
sudo apt install rclone

# Arch/SteamOS
sudo pacman -S rclone

# macOS
brew install rclone

# Termux
pkg install rclone
```

### 2. Configure MEGA in rclone

Run the rclone config wizard and create a remote named `mega`:

```bash
rclone config
```

When prompted:
- **Name**: `mega`
- **Type**: `s3`
- **Provider**: `Other` (for MEGA's S3 service)
- **Access Key ID**: Your MEGA access key
- **Secret Access Key**: Your MEGA secret key
- **Endpoint**: `s3.ca-central-1.s4.mega.io` (or your region's S4 endpoint)

> **Note**: If you don't have MEGA S4 credentials, sign up at [MEGA.nz](https://mega.nz) and enable S4 storage in your account settings.

### 3. Verify Setup

Run the validation script to confirm everything is configured:

```bash
./validate_rclone
```

You should see:
```
Validation passed: rclone and MEGA are properly configured.
Using Emulation directory: /home/deck/Emulation
```

## Usage

### Quick Start: dotfiles-emudeck

The `dotfiles-emudeck` orchestrator provides an interactive menu for all operations:

```bash
./dotfiles-emudeck
```

This menu-driven tool allows you to:
1. Validate rclone and MEGA configuration
2. Sync all emulator data to MEGA
3. Sync individual emulators (RetroArch, PCSX2, Flycast)
4. Setup automatic syncing with systemd timer
5. Check timer status
6. Disable automatic syncing

### Manual Syncing

#### Sync all emulators

```bash
./sync_retroarch_to_mega
./sync_pcsx2_to_mega
./sync_flycast_to_mega
```

#### Sync individual emulators

```bash
# RetroArch only
./sync_retroarch_to_mega

# PCSX2 only
./sync_pcsx2_to_mega

# Flycast only
./sync_flycast_to_mega
```

### Automatic Syncing with Systemd Timer

Setup automatic syncing every 15 minutes:

```bash
./dotfiles-emudeck
# Select option 6: Setup automatic syncing with systemd timer
```

This creates:
- `/home/deck/.config/systemd/user/emudeck-sync.service` — Service definition
- `/home/deck/.config/systemd/user/emudeck-sync.timer` — Timer definition (15-minute intervals)

The timer will:
- Start syncing 5 minutes after boot
- Sync all emulator data every 15 minutes
- Run silently in the background with journal logging

#### Check Timer Status

```bash
./dotfiles-emudeck
# Select option 7: Check systemd timer status
```

Or manually:
```bash
systemctl --user status emudeck-sync.timer
systemctl --user list-timers emudeck-sync.timer
```

#### Disable Timer

```bash
./dotfiles-emudeck
# Select option 8: Disable automatic syncing
```

Or manually:
```bash
systemctl --user disable --now emudeck-sync.timer
```

## Directory Structure

### Local (Source) - EmuDeck Standard

```
~/Emulation/
├── saves/
│   ├── retroarch/
│   │   ├── saves/           (symlink to Flatpak RetroArch saves)
│   │   ├── states/          (symlink to Flatpak RetroArch states)
│   │   └── config/          (symlink to core overrides)
│   ├── pcsx2/
│   │   ├── saves/           (PS2 memory cards)
│   │   └── states/          (PS2 save states)
│   ├── flycast/
│   │   ├── saves/           (symlink to Flycast VMU saves)
│   │   └── states/          (symlink to Flycast states)
│   └── ...

~/.config/retroarch/
├── system/                  (RetroArch NVRAM files)
├── cheats/                  (RetroArch cheat files)
└── ...

~/.var/app/org.flycast.Flycast/     (Flycast Flatpak)
├── config/
│   ├── data/flycast/        (save states)
│   └── flycast/             (config files)
└── data/
    └── flycast/             (saves, custom textures)
```

### Cloud (MEGA S4)

```
mega:emudeck-data/
├── retroarch/
│   ├── saves/
│   ├── states/
│   ├── config/
│   ├── nvram/
│   └── cheats/
├── pcsx2/
│   ├── saves/
│   └── states/
├── flycast/
│   ├── saves/
│   ├── states/
│   ├── config/
│   └── data/
└── ...
```

## Troubleshooting

### "ERROR: rclone is not installed"

Install rclone using your package manager (see Prerequisites above).

### "ERROR: MEGA configuration 'mega' not found in rclone"

Run `rclone config` and create a remote named `mega`. Verify with:

```bash
rclone listremotes
```

### "ERROR: Emulation directory not found"

The script looks for `~/Emulation/` by default. If EmuDeck is installed elsewhere:
- Custom path (SD card): The script will prompt you to enter the correct path
- Example: `/media/deck/sd/Emulation`

### Sync is slow or timing out

For large file collections, consider:
- Using `--max-transfer` flag in rclone
- Running syncs during off-peak hours
- Breaking into smaller manual syncs

### Flatpak Permission Issues

If you see permission denied errors for Flatpak apps (RetroArch, Flycast):
1. Verify the app is installed: `flatpak list --app`
2. Ensure Flatpak directory exists: `ls -la ~/.var/app/`
3. Check file permissions: `ls -la ~/.var/app/org.libretro.RetroArch/`

### Symlink Issues

The scripts use `--copy-links` flag to follow Flatpak symlinks to their actual locations. If symlinks aren't working:
1. Verify EmuDeck setup created symlinks: `ls -la ~/Emulation/saves/retroarch/`
2. Check target paths exist: `ls -la ~/.var/app/org.libretro.RetroArch/`

## Advanced Usage

### Dry-run (preview changes without syncing)

```bash
rclone sync --dry-run ~/Emulation/saves/retroarch/ mega:emudeck-data/retroarch/
```

### Custom bandwidth limits

```bash
rclone sync --bwlimit 10M ~/Emulation/saves/retroarch/ mega:emudeck-data/retroarch/
```

### List cloud contents

```bash
rclone ls mega:emudeck-data/
rclone ls mega:emudeck-data/retroarch/saves/
```

### Delete old cloud backups

```bash
rclone purge mega:emudeck-data/retroarch/saves/old_game/
```

## File Locations Reference

| Item | Path |
|---|---|
| Scripts directory | `./emudeck/bin/` |
| Main orchestrator | `./emudeck/bin/dotfiles-emudeck` |
| RetroArch sync | `./emudeck/bin/sync_retroarch_to_mega` |
| PCSX2 sync | `./emudeck/bin/sync_pcsx2_to_mega` |
| Flycast sync | `./emudeck/bin/sync_flycast_to_mega` |
| Restore script | `./emudeck/bin/restore_retroarch_from_mega` |
| Validation script | `./emudeck/bin/validate_rclone` |
| Systemd service | `~/.config/systemd/user/emudeck-sync.service` |
| Systemd timer | `~/.config/systemd/user/emudeck-sync.timer` |

## Contributing

Issues, feature requests, and pull requests welcome! This is part of the [dotfiles](https://github.com/jcchikikomori/.dotfiles) repository.

## License

See the main dotfiles repository for license information.
