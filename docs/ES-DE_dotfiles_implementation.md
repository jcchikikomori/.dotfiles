# ES-DE Dotfiles Integration Guide

**Purpose:** Reference guide for implementing ES-DE configuration sync in your EmuDeck dotfiles system.

---

## Current State Assessment

**File location in dotfiles:**

- Will be: `steamos/systems/.config/ES-DE/` → symlinked to `$HOME/ES-DE`

**OR alternative structure:**

- `steamos/systems/.local/share/ES-DE/` (less common but valid)

---

## Recommended Package Structure

### Option 1: Single Package (Recommended)

```bash
# In your stowme.sh
steamos/systems  # Stows entire systems tree, including ES-DE

# Directory structure:
steamos/systems/
├── .local/
│   └── bin/
│       ├── org.jcchikikomori.dotfiles/bin/
│       │   └── dotfiles-*
│       └── org.jcchikikomori.devtools/bin/
│           └── devtools-*
├── .config/
│   └── ES-DE/
│       ├── es_settings.xml
│       ├── es_input.cfg
│       ├── gamelists/
│       │   ├── ps2/
│       │   │   └── gamelist.xml
│       │   ├── n64/
│       │   └── ...
│       └── collections/
│           └── favorites.m3u

# After stow -t $HOME steamos/systems:
# ~/.config/ES-DE → ..dotfiles/steamos/systems/.config/ES-DE (symlink)
```

**Pros:**

- Single package; easy to maintain
- All settings together
- Integrates with existing dotfiles structure

**Cons:**

- If gamelists are large (>1 MB), git commit becomes heavy

### Option 2: Separate Package (For Large Collections)

```bash
# Split into two packages in stowme.sh
steamos/systems              # Non-media config
steamos/es-de-media          # Large gamelists/media (optional)

# Allows git to stay lightweight while media handled separately
# (e.g., via Restic, rclone, or ignored in .gitignore)
```

---

## Implementation Steps

### 1. Prepare ES-DE Config on Source Device

```bash
# On source Steam Deck (master device):
cd ~/.dotfiles

# Back up current ES-DE config
mkdir -p backups
cp -r ~/ES-DE backups/ES-DE-$(date +%Y%m%d)

# Create target directory in dotfiles
mkdir -p steamos/systems/.config/ES-DE/

# Copy only ESSENTIAL files (skip media cache)
cp ~/ES-DE/es_settings.xml steamos/systems/.config/ES-DE/
cp ~/ES-DE/es_input.cfg steamos/systems/.config/ES-DE/  # optional
cp -r ~/ES-DE/gamelists steamos/systems/.config/ES-DE/
cp -r ~/ES-DE/collections steamos/systems/.config/ES-DE/

# Optional: Copy themes if < 100 MB
du -sh ~/ES-DE/themes
# If < 100 MB:
cp -r ~/ES-DE/themes steamos/systems/.config/ES-DE/

# Check size
du -sh steamos/systems/.config/ES-DE/
```

### 2. Add to Stow Configuration

**In `steamos/stowme.sh`** (if distro-specific wrapper):

```bash
#!/bin/sh
# Delegate to root stowme.sh
exec "$HOME/.dotfiles/stowme.sh" "$@"
```

**In root `stowme.sh`** (main config):

```bash
#!/bin/sh

PACKAGES=(
    "root/systems"
    "linux/zsh"
    "linux/tmux"
    "linux/nvim"
    "steamos/systems"        # ← Adds ES-DE config
)

# ... rest of script
```

### 3. Handle Symlink Validation

**Create pre-stow check** in `linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-pre-stow`:

```bash
#!/bin/sh
# Pre-stow validation for ES-DE config

# Check for conflicting files before stowing
CONFLICT_FILES="$HOME/ES-DE"

if [ -d "$CONFLICT_FILES" ] && [ ! -L "$CONFLICT_FILES" ]; then
    echo "⚠️  ES-DE config directory exists but is not a symlink:"
    echo "   $CONFLICT_FILES"
    echo ""
    echo "This will block stow. Options:"
    echo "  1. Backup: cp -r $HOME/ES-DE ~/Backups/ES-DE-backup"
    echo "  2. Remove: rm -rf $HOME/ES-DE"
    echo "  3. Merge: Copy ~/ES-DE/* to dotfiles first"
    echo ""
    read -p "Proceed with stow? (y/n): " -r
    if [ ! "$REPLY" = "y" ]; then
        exit 1
    fi
fi

exit 0
```

### 4. Test Stow Dry-Run

```bash
cd ~/.dotfiles

# Dry-run to see what would be symlinked
stow -n -v -t $HOME steamos/systems

# Expected output:
# SYMLINK: .config/ES-DE/es_settings.xml => ../.dotfiles/steamos/systems/.config/ES-DE/es_settings.xml
# SYMLINK: .config/ES-DE/gamelists => ../.dotfiles/steamos/systems/.config/ES-DE/gamelists
# ...

# If no conflicts, execute:
stow -t $HOME steamos/systems
```

### 5. Verify Symlinks

```bash
# Check symlinks were created correctly
ls -la ~/.config/ES-DE/

# Should show:
# lrwxr-xr-x 1 deck deck ... es_settings.xml -> ../../.dotfiles/steamos/systems/.config/ES-DE/es_settings.xml
# lrwxr-xr-x 1 deck deck ... gamelists -> ../../.dotfiles/steamos/systems/.config/ES-DE/gamelists

# Verify content accessible
cat ~/.config/ES-DE/es_settings.xml | head -5
```

### 6. Boot ES-DE to Confirm

```bash
# Launch ES-DE
/home/deck/Applications/ES-DE.AppImage

# Check that:
# ✓ Your settings loaded (theme, language, view preferences)
# ✓ Controller mappings work (if synced es_input.cfg)
# ✓ Game lists display correctly
# ✓ Collections/playlists appear
```

---

## Git Workflow

### Add to Git

```bash
git add steamos/systems/.config/ES-DE/

# Check what was staged
git status

# Review differences
git diff --cached steamos/systems/.config/ES-DE/
```

### Commit (User Approval Required)

```bash
# Prepare commit message
git commit -m "feat: add ES-DE configuration for portable setup"

# Or more detailed:
git commit -m "feat: add ES-DE config (settings, gamelists, collections)

- Include es_settings.xml for UI preferences
- Include gamelists/ for game metadata (100-500 KB)
- Include collections/ for user playlists
- Exclude downloaded_media/ (regenerable; saves storage)

Sync size: ~50-100 KB
Migration: Re-scrape media on target device (~2 hours)
"
```

### Push (User Approval Required)

```bash
git push origin main
```

---

## Handling Large Gamelists

If `gamelists/` folder is > 1 MB:

### Option A: Keep in Git (Simple but Heavy)

```bash
# Add LFS for large XML files
git lfs install
git lfs track "steamos/systems/.config/ES-DE/gamelists/**/*.xml"
git add .gitattributes
```

### Option B: Exclude from Git (Lightweight)

```bash
# Add to .gitignore
echo "steamos/systems/.config/ES-DE/gamelists/" >> .gitignore

# Sync gamelists separately via Restic/backup tool
# Dotfiles gets: es_settings.xml, es_input.cfg, collections/ only (~50 KB)
```

### Option C: Selective Compression

```bash
# Store only compressed backup, regenerate on target
cd steamos/systems/.config/ES-DE/
tar -czf gamelists.tar.gz gamelists/
rm -rf gamelists/

git add gamelists.tar.gz

# Post-stow: Create script to extract
# echo "tar -xzf ~/.config/ES-DE/gamelists.tar.gz -C ~/.config/ES-DE/" >> dotfiles-post-stow
```

---

## Handling Themes (Optional)

### Skip Themes (Recommended for Most Users)

```bash
# Don't commit themes; use Theme Downloader on target
# In .gitignore:
echo "steamos/systems/.config/ES-DE/themes/" >> .gitignore

# Note: User can re-download via ES-DE UI
```

### Include Themes (If Small)

```bash
# Only if total size < 50 MB
du -sh ~/ES-DE/themes

# If under limit:
cp -r ~/ES-DE/themes steamos/systems/.config/ES-DE/
git add steamos/systems/.config/ES-DE/themes/
```

---

## Media Cache Handling (Separate System)

**RECOMMENDATION:** Do NOT sync media cache via dotfiles.

Instead, set up external sync:

### Option 1: Restic Backup

```bash
# Backup media separately
restic backup ~/Emulation/tools/downloaded_media/
```

### Option 2: Rclone Sync

```bash
# Sync to cloud (Google Drive, Nextcloud, etc.)
rclone sync ~/Emulation/tools/downloaded_media/ gdrive:EmuDeck/media/
```

### Option 3: Manual Re-Scrape (Free, Space-Saving)

```bash
# Just keep dotfiles config
# On target device, after stowing:
# 1. Boot ES-DE
# 2. Start → Scrape
# 3. Select Systems
# 4. Start scraping
# (Takes 2-6 hours depending on collection size)
```

---

## Testing Checklist

After implementing ES-DE stow:

- [ ] **Pre-stow:** No conflicting `~/.config/ES-DE` directory
- [ ] **Stow:** All files symlinked correctly
- [ ] **Boot:** ES-DE launches without errors
- [ ] **Settings:** Preferences loaded (verify theme, language)
- [ ] **Controller:** Input mappings work (if synced)
- [ ] **Games:** Gamelists display with metadata
- [ ] **Collections:** User playlists visible
- [ ] **Themes:** Custom themes load correctly (if synced)
- [ ] **Git:** Changes staged, ready for commit

---

## Rollback Procedure

If ES-DE stow causes issues:

```bash
# 1. Undo stow
stow -D -t $HOME steamos/systems

# 2. Restore from backup (created in step 1)
cp -r ~/Backups/ES-DE-backup/* ~/.config/ES-DE/

# 3. Verify
ls -la ~/.config/ES-DE/
/home/deck/Applications/ES-DE.AppImage

# 4. Debug & fix
# Check error messages in ~ES-DE/es_log.txt
cat ~/ES-DE/es_log.txt
```

---

## Summary

**ES-DE Dotfiles Integration:**

| Step | Command | Time |
|------|---------|------|
| Backup | `cp -r ~/ES-DE ~/Backups/` | < 1 min |
| Copy config | `cp ~/ES-DE/{es_*.xml,gamelists,collections} ~/.dotfiles/steamos/systems/.config/ES-DE/` | < 1 min |
| Stow dry-run | `stow -n -t $HOME steamos/systems` | < 1 sec |
| Stow apply | `stow -t $HOME steamos/systems` | < 1 sec |
| Test | Boot ES-DE, verify settings | < 1 min |
| Git add | `git add steamos/systems/.config/ES-DE/` | < 1 min |
| Git commit | `git commit -m "..."` | < 1 min |
| Git push | `git push origin main` | 1-5 min |

**Estimated sync size:** 50-500 KB (metadata only)
**Estimated total time:** 10-15 minutes
**Migration to new device:** Re-scrape media (2-8 hours) or use separate media backup tool

---

## Key Takeaway

ES-DE config is **highly portable** because it's pure XML + lightweight. Only sync metadata, not media cache. On target device, either:

1. Re-scrape media (free but time-consuming)
2. Restore media separately (via Restic/rclone)
3. Accept minimal UI until user downloads themes/media
