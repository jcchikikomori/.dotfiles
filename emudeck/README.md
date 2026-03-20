# EmuDeck MEGA S4 Cloud Sync

Cloud sync support for EmuDeck using **rclone** and **MEGA S4** (S3-compatible storage). This enables seamless backup and restore of game saves, save states, and RetroArch configurations across devices.

## Overview

This suite provides two primary workflows:

1. **Backup to Cloud** — Sync local RetroArch data to MEGA S4 bucket
2. **Restore from Cloud** — Pull RetroArch data back from MEGA S4 bucket

### What Gets Synced?

- **Save Files**: Game saves stored in `saves/` directory
- **Save States**: Emulator save states in `states/` directory
- **Core Configurations**: RetroArch core-specific overrides, shaders, and remaps in `config/` directory

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

### Sync to MEGA (Backup)

```bash
./sync_retroarch_to_mega
```

This will:
1. Detect your Emulation directory (or prompt if custom location)
2. Sync save files to `mega:emudeck-data/retroarch/saves`
3. Sync save states to `mega:emudeck-data/retroarch/states`
4. Sync core configs to `mega:emudeck-data/retroarch/config`

**Example Output:**
```
Syncing RetroArch data from /home/deck/Emulation/saves/retroarch to mega:emudeck-data/retroarch...

Items being synced:
  - Save files (saves/)
  - Save states (states/)
  - Configuration overrides (config/)
    • Core-specific configs (.cfg files)
    • Shader presets (.slangp, .glslp files)
    • Controller remaps (.rmp files)

Syncing save files...
2024/03/20 15:30:45 INFO  : Creating directory structure
2024/03/20 15:30:46 INFO  : zelda_link_to_the_past.srm: Copied
...
RetroArch data synced successfully to mega:emudeck-data/retroarch/
```

### Restore from MEGA

```bash
./restore_retroarch_from_mega
```

This will:
1. Prompt for confirmation (to prevent accidental overwrites)
2. Check for data on MEGA
3. Pull saves, states, and configs back to local Emulation directory

**Example Output:**
```
WARNING: This will restore RetroArch data from MEGA to your local system.
Items to be restored:
  - Save files (saves/)
  - Save states (states/)
  - Configuration overrides (config/)
    • Core-specific configs (.cfg files)
    • Shader presets (.slangp, .glslp files)
    • Controller remaps (.rmp files)

Continue with restore? (yes/no): yes
Restoring save files from mega:emudeck-data/retroarch/saves...
2024/03/20 15:35:12 INFO  : zelda_link_to_the_past.srm: Copied
...
RetroArch data restored successfully from mega:emudeck-data/retroarch/
```

## Directory Structure

### Local (Source)

```
~/Emulation/saves/retroarch/
├── saves/                  # Game save files
│   ├── game1.srm
│   ├── game2.srm
│   └── ...
├── states/                 # Emulator save states
│   ├── game1.state
│   ├── game1.state.auto
│   └── ...
└── config/                 # Core overrides & configurations
    ├── FinalBurn Neo.cfg
    ├── Nestopia.cfg
    ├── shader_presets/
    │   └── my_shader.slangp
    └── remaps/
        └── NES.rmp
```

### Cloud (MEGA S4)

```
mega:emudeck-data/retroarch/
├── saves/                  # Mirrored from local
├── states/                 # Mirrored from local
└── config/                 # Mirrored from local
```

## Scheduling Automatic Syncs (Optional)

You can automate syncs using cron or systemd timers.

### Cron Job (Sync every 2 hours)

Add to your crontab (`crontab -e`):

```bash
0 */2 * * * /path/to/emudeck/bin/sync_retroarch_to_mega >> ~/.logs/retroarch_sync.log 2>&1
```

### Systemd Timer (Sync every 2 hours)

Create `/etc/systemd/user/retroarch-sync.service`:

```ini
[Unit]
Description=RetroArch MEGA S4 Sync
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/home/deck/Projects/dotfiles/emudeck/bin/sync_retroarch_to_mega
StandardOutput=journal
StandardError=journal
```

Create `/etc/systemd/user/retroarch-sync.timer`:

```ini
[Unit]
Description=RetroArch MEGA S4 Sync Timer
Requires=retroarch-sync.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=2h
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and start:

```bash
systemctl --user enable --now retroarch-sync.timer
```

## Troubleshooting

### "ERROR: rclone is not installed"

Install rclone using your package manager (see Prerequisites above).

### "ERROR: MEGA configuration 'mega' not found in rclone"

Run `rclone config` and create a remote named `mega`. Verify with:

```bash
rclone listremotes
```

### "ERROR: RetroArch directory not found"

The script looks for `~/Emulation/saves/retroarch/`. If EmuDeck is installed elsewhere:
- Custom path (SD card): The script will prompt you to enter the correct path
- Example: `/media/deck/sd/Emulation`

### Sync is slow or timing out

For large file collections, consider:
- Using `--max-transfer` flag in rclone (see rclone docs)
- Running syncs during off-peak hours
- Breaking into smaller manual syncs: `rclone sync saves/` then `rclone sync states/` then `rclone sync config/`

### Permission denied errors

Ensure rclone has read/write access to:
- Local RetroArch directories: `~/Emulation/saves/retroarch/`
- MEGA S4 bucket: Check your rclone credentials

### Symlink issues (Flatpak RetroArch)

The `--copy-links` flag follows Flatpak symlinks to their actual locations. If you see "permission denied":
1. Verify RetroArch Flatpak is installed: `flatpak list --app | grep RetroArch`
2. Check Flatpak data directory: `~/.var/app/org.libretro.RetroArch/config/retroarch/`

## Advanced Usage

### Dry-run (preview changes without syncing)

```bash
rclone sync --dry-run ~/Emulation/saves/retroarch/ mega:emudeck-data/retroarch/
```

### Custom bandwidth limits

```bash
rclone sync --bwlimit 10M ~/Emulation/saves/retroarch/ mega:emudeck-data/retroarch/
```

### Exclude certain file types

Modify the sync scripts to add `--exclude` flags:

```bash
rclone sync \
  --exclude '*.bak' \
  --exclude '*.tmp' \
  "$RETROARCH_DIR/saves/" \
  "mega:emudeck-data/retroarch/saves" \
  --verbose --copy-links
```

## Contributing

Issues, feature requests, and pull requests welcome! This is part of the [dotfiles](https://github.com/jcchikikomori/dotfiles) repository.

## License

See the main dotfiles repository for license information.
