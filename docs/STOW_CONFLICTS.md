# Stow Conflict Resolution & Prevention Guide

## GitHub Issue #91: EmuDeck SystemD File Conflicts

### Problem Summary

When adding new configuration files to the dotfiles repo, if those files already exist in the user's home directory as **real files** (not symlinks), GNU Stow will refuse to create symlinks and fail with:

```bash
ERROR: stow failed to create link /home/user/.config/systemd/user/emudeck-sync.service
  In directory /home/user/.config/systemd/user
  "emudeck-sync.service" already exists
```

This happened with:

- `~/.config/systemd/user/emudeck-sync.service`
- `~/.config/systemd/user/emudeck-sync.timer`

### Root Cause

During EmuDeck testing, actual files were created manually in the user's home directory. Later, when these files were added to the dotfiles repo, stow couldn't link them because:

1. **Real files took precedence** — Stow sees the real file first
2. **Content mismatch risk** — Stow won't blindly overwrite existing files
3. **User data loss concern** — Removing files directly could lose user configurations

### Solution

The conflict was resolved using the three-step workflow documented below.

---

## Workflow: Adding New Config Files to Dotfiles

### Step 1: Create the New File in Dotfiles

Add your new configuration file to the appropriate package:

```sh
cd ~/.dotfiles

# For Linux systems (SteamOS, Ubuntu, Debian, Arch, RHEL):
mkdir -p linux/systems/.config/systemd/user
echo "[Unit]
Description=EmuDeck Sync Service
..." > linux/systems/.config/systemd/user/emudeck-sync.service

# For macOS-specific configs:
mkdir -p darwin/systems/.config/myapp
echo "..." > darwin/systems/.config/myapp/config.toml
```

### Step 2: Check for Conflicts

**Before stowing**, run the comprehensive conflict checker:

```sh
dotfiles-conflicts-comprehensive
```

This will report:

- `SAFE` — File exists as a dotfiles symlink (already stowed, no action needed)
- `CLEAN` — File doesn't exist (ready to stow)
- `BLOCKING` — File exists as a real file or non-dotfiles symlink (cleanup required)

### Step 3: Resolve Blocking Conflicts

If conflicts are found, backup and remove the real files:

```sh
# Backup existing files with timestamp
cp -r ~/.config/systemd ~/backup-systemd-$(date +%Y%m%d-%H%M%S)

# Remove only the conflicting files
rm -f ~/.config/systemd/user/emudeck-sync.service
rm -f ~/.config/systemd/user/emudeck-sync.timer

# Verify CLEAN status
dotfiles-conflicts-comprehensive
```

### Step 4: Stow the Package

```sh
cd ~/.dotfiles
stowme.sh systems
```

Or if using dotstow directly:

```sh
cd ~
dotstow stow systems
```

### Step 5: Verify the Link

```sh
# Check that files are now symlinks to dotfiles
ls -la ~/.config/systemd/user/emudeck-sync.*
readlink ~/.config/systemd/user/emudeck-sync.service

# Reload systemd and test the service
systemctl --user daemon-reload
systemctl --user status emudeck-sync.service
```

---

## Tools & Scripts

### `dotfiles-conflicts`

Checks known problematic files that have caused conflicts before:

- wireplumber config (`~/.config/wireplumber`)
- opencode config (`~/.config/opencode`)
- emudeck systemd services (`~/.config/systemd/user/emudeck-sync.*`)

```sh
dotfiles-conflicts              # Non-fatal; reports but continues
dotfiles-conflicts --strict     # Strict mode; exits 1 on blocking conflicts
```

**Usage in stowme.sh:**

The root `stowme.sh` calls `dotfiles-conflicts` automatically before stowing:

```sh
# From stowme.sh line 161-165
if ! sh "$DOTFILES_PATH/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-conflicts"; then
  log_error "Error: conflict helper failed."
  restore_external_symlinks
  exit 1
fi
```

### `dotfiles-conflicts-comprehensive`

Scans **all** files in all dotfiles packages and reports conflicts:

```sh
dotfiles-conflicts-comprehensive              # Report all conflicts
dotfiles-conflicts-comprehensive --strict     # Exit 1 if any found
```

This tool helps prevent future conflicts when adding new files to dotfiles.

---

## Best Practices

### When Adding New Configuration Files

1. **Check for pre-existing files FIRST**

   ```sh
   # Before adding to dotfiles, check if file exists in home
   ls -la ~/.config/myapp/myconfig.yml
   ```

   If it exists, decide:
   - **Move it to dotfiles** → Back up, remove, add to repo
   - **Keep it personal** → Don't add to dotfiles (add to `.gitignore` if needed)

2. **Use the conflict checker as a safety net**

   ```sh
   # After adding new files to dotfiles:
   dotfiles-conflicts-comprehensive

   # This catches conflicts before they break stowing
   ```

3. **Document the file in comments**

   ```sh
   # In dotfiles file:
   # GitHub #91: This file was added to prevent manual recreation
   # If you have an existing version at ~/.config/systemd/user/emudeck-sync.service,
   # back it up and remove it before running stowme.sh
   ```

### When Troubleshooting Stow Failures

1. **Run the conflict checker first**

   ```sh
   dotfiles-conflicts-comprehensive
   ```

   This identifies the blocking files.

2. **Backup user files**

   ```sh
   cp -r ~/.config/systemd ~/backup-systemd-$(date +%Y%m%d)
   ```

   Always backup before removing.

3. **Remove conflicting files**

   ```sh
   rm ~/.config/systemd/user/emudeck-sync.service
   rm ~/.config/systemd/user/emudeck-sync.timer
   ```

4. **Re-run the checker**

   ```sh
   dotfiles-conflicts-comprehensive
   ```

   All targets should now be `CLEAN`.

5. **Re-run stow**

   ```sh
   stowme.sh
   ```

---

## Implementation Details

### How the Conflict Checkers Work

Both scripts follow this logic for each target file:

```text
if file is a symlink:
  if symlink target is inside DOTFILES_PATH:
    → SAFE (already stowed correctly)
  else:
    → BLOCKING (points outside dotfiles)
else if file exists as regular file:
  if file path is inside DOTFILES_PATH:
    → SAFE (unlikely, but theoretically safe)
  else:
    → BLOCKING (real file not in dotfiles)
else:
  → CLEAN (file doesn't exist, ready to stow)
```

### Adding New Conflict Targets

To add new files to the conflict checkers:

**For known problematic files** (add to `dotfiles-conflicts`):

```sh
# Edit: linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-conflicts

echo '[dotfiles-conflicts] Checking stow target conflicts (mynewservice)'

for target in \
  "$HOME/.config/mynewservice" \
  "$HOME/.config/mynewservice/config.yml"
do
  if ! status_line "$target"; then
    BLOCKING=1
  fi
done
```

**For comprehensive scanning** (automatic via `dotfiles-conflicts-comprehensive`):

The comprehensive tool scans all files in all packages automatically. No changes needed.

---

## Distro-Specific Considerations

### Linux (debian, ubuntu, arch, steamos, rhel)

- Systemd files go in: `linux/systems/.config/systemd/user/`
- All distros use systemd; no special handling per distro

### macOS (darwin)

- Systemd not available; use LaunchAgent instead
- Configuration goes in: `darwin/systems/Library/LaunchAgents/`
- Stow automatically excludes `linux/` packages on macOS

### Termux

- No systemd support; use startup scripts
- Configuration goes in: `termux/systems/.local/share/termux-startup.d/`

---

## References

- **GitHub Issue:** #91 - emudeck-sync systemd files caused stow conflicts
- **Root Stow Script:** `./stowme.sh` (lines 149-165)
- **Conflict Helper:** `./linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-conflicts`
- **Comprehensive Checker:** `./linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-conflicts-comprehensive`
- **GNU Stow Docs:** <https://www.gnu.org/software/stow/manual/stow.html#The-Stow-Algorithm>

---

## Quick Reference

```sh
# Check for conflicts before stowing
dotfiles-conflicts-comprehensive

# Backup a potentially conflicting directory
cp -r ~/.config/mydir ~/backup-mydir-$(date +%Y%m%d)

# Remove conflicting files
rm -f ~/.config/mydir/filename

# Verify cleanup
dotfiles-conflicts-comprehensive

# Stow the package
stowme.sh

# Verify symlinks were created
ls -la ~/.config/mydir/filename
readlink ~/.config/mydir/filename
```
