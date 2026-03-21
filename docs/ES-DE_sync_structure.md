# ES-DE/EmulationStation Directory Structure & Sync Strategy

**Last Updated:** March 2025 | **Based on:** Official EmuDeck Documentation
**Source:** <https://emudeck.github.io/tools/steamos/es-de/>

---

## Overview

ES-DE (EmulationStation Desktop Edition) is a **native AppImage** frontend (not Flatpak) installed by EmuDeck. On Steam Deck, configuration is split between:

- **User settings directory:** `$HOME/ES-DE` (hidden by default, use `$HOME` = `/home/deck`)
- **Media/artwork cache:** `Emulation/tools/downloaded_media`
- **Application:** `/home/deck/Applications/ES-DE.AppImage`

**Key insight:** ES-DE 3.0 migration note: Old versions used `~/.emulationstation` (hidden folder), ES-DE 3.0+ uses `~/ES-DE` (regular folder).

---

## Complete Directory Structure

```text
$HOME/ES-DE/
├── es_settings.xml                    [CORE CONFIG - ~5KB]
├── es_input.cfg                       [OPTIONAL - controller mapping, ~2KB]
├── es_log.txt                         [TRANSIENT - log file]
├── collections/                       [User playlists - ~1KB per collection]
│   └── (empty by default, populated on user action)
├── custom_systems/
│   └── es_systems.xml                 [OPTIONAL - custom system definitions]
├── gamelists/                         [METADATA - game info/ratings/descriptions]
│   ├── atarilynx/
│   │   └── gamelist.xml               [~10-100KB depending on library size]
│   ├── gc/
│   │   └── gamelist.xml
│   ├── n3ds/
│   │   └── gamelist.xml
│   ├── nds/
│   │   └── gamelist.xml
│   ├── ps2/
│   │   └── gamelist.xml
│   ├── psp/
│   │   └── gamelist.xml
│   ├── psx/
│   │   └── gamelist.xml
│   ├── saturn/
│   │   └── gamelist.xml
│   ├── scummvm/
│   │   └── gamelist.xml
│   ├── wii/
│   │   └── gamelist.xml
│   └── [other system folders...]
└── themes/                            [UI themes - downloaded/installed]
    ├── epic-noir-revisited-es-de/     [~5-50MB per theme]
    └── [other theme folders...]

Emulation/tools/downloaded_media/      [SCRAPED MEDIA - artwork, screenshots]
├── CLEANUP/                           [Transient cleanup marker]
├── [system folders]/
│   ├── media_screenshots/             [~1-2MB per game]
│   ├── media_fanart/                  [~2-5MB per game]
│   ├── media_cover/                   [~500KB per game]
│   ├── media_marquee/                 [~200KB per game]
│   └── media_3dbox/                   [~1-3MB per game if available]
└── [more system folders...]
```

---

## File-by-File Sync Recommendations

### CORE FILES (MUST SYNC - Critical for UX)

| File/Dir | Size Est. | Purpose | Sync? | Notes |
|----------|-----------|---------|-------|-------|
| `es_settings.xml` | 5-20 KB | All UI settings (theme, language, scraper source, view modes) | **YES** | Essential for maintaining user preferences |
| `gamelists/*/gamelist.xml` | 10-500 KB/system | Game metadata (title, desc, rating, release date, developer) | **YES** | User effort to recreate (scraping takes hours); high value to sync |
| `collections/*` | 1-10 KB each | User-created playlists/favorites | **YES** | Hand-curated, impossible to recreate |
| `custom_systems/es_systems.xml` | 2-10 KB | Custom system definitions (if user added non-standard systems) | **YES** | Only exists if user customized |

**Estimated core sync size: 50-1000 KB** (very manageable)

---

### OPTIONAL FILES (RECOMMEND SYNC - Nice-to-Have)

| File/Dir | Size Est. | Purpose | Sync? | Notes |
|----------|-----------|---------|-------|-------|
| `es_input.cfg` | 2-5 KB | Controller button mappings | **YES** | One-time setup; good to preserve |
| `themes/` | 5-200 MB | UI theme folders (downloaded) | **CONDITIONAL** | Large; only sync if user has many custom themes; themes can be re-downloaded via Theme Downloader |

**Estimated optional sync size: 5-200 MB** (depends on theme count)

---

### MEDIA CACHE (CONSIDER SKIP - Large, Regenerable)

| File/Dir | Size Est. | Purpose | Sync? | Rationale |
|----------|-----------|---------|-------|-----------|
| `downloaded_media/` | 100 MB - 10+ GB | Scraped artwork (covers, fanart, screenshots, 3D boxes, marquees) | **CONDITIONAL** | **Pros:** User has nice visuals immediately on new device. **Cons:** Massive storage; can be re-scraped in hours; accounts for 95%+ of total sync size. **Recommendation:** Skip unless user has <500MB media folder. If syncing full collection, expect multi-hour first sync. |

---

### TRANSIENT FILES (DO NOT SYNC)

| File | Reason |
|------|--------|
| `es_log.txt` | Log file; regenerated each session |
| `downloaded_media/CLEANUP/` | Marker file for internal cleanup; transient |

---

## Sync Recommendations by Use Case

### **Scenario 1: Casual User (< 50 games)**

```text
SYNC:
  ✓ es_settings.xml           (~5 KB)
  ✓ gamelists/*/gamelist.xml  (~50 KB)
  ✓ collections/              (~5 KB)
  ✓ es_input.cfg              (~2 KB)
  ✓ themes/ (if any)          (~10 MB)
  ✓ downloaded_media/         (~100-200 MB)

TOTAL: ~110-210 MB
TIME TO SYNC: <1 minute
RECOVERY TIME: 30 minutes (re-scrape if needed)
```

### **Scenario 2: Power User (100-500 games)**

```text
SYNC:
  ✓ es_settings.xml           (~10 KB)
  ✓ gamelists/*/gamelist.xml  (~500 KB)
  ✓ collections/              (~50 KB)
  ✓ es_input.cfg              (~2 KB)
  ✓ themes/ (if any)          (~50 MB)
  ✓ downloaded_media/         (~1-3 GB)

TOTAL: ~1-3.1 GB
TIME TO SYNC: 2-5 minutes
RECOVERY TIME: 2-4 hours (re-scrape)
```

### **Scenario 3: Massive Collection (1000+ games)**

```text
SYNC:
  ✓ es_settings.xml           (~20 KB)
  ✓ gamelists/*/gamelist.xml  (~2 MB)
  ✓ collections/              (~100 KB)
  ✓ es_input.cfg              (~2 KB)
  ✓ themes/ (if any)          (~100 MB)
  ✗ downloaded_media/         (5-20 GB - SKIP or compress)

RECOMMENDED APPROACH:
  - Sync metadata (.xml files): ~2.1 MB
  - Sync themes: ~100 MB
  - SKIP media cache or selective sync (highest-rated games only)
  - Use Theme Downloader on target device
  - Re-scrape top favorites on target after first boot

TOTAL (metadata + themes): ~102 MB
TIME TO SYNC: 1 minute
RECOVERY TIME (media): 4-8 hours (or skip and live without artwork)
```

---

## Directory Sync Strategy

### **1. MINIMUM VIABLE SYNC (Portable Setup)**

Only sync what's irreplaceable. Re-scrape media on target device.

```yaml
sync_path: $HOME/ES-DE/

include:
  - es_settings.xml
  - es_input.cfg
  - gamelists/          # All .xml files (metadata)
  - collections/        # User playlists
  - custom_systems/     # If exists

exclude:
  - es_log.txt
  - themes/             # Can be re-downloaded
  - downloaded_media/   # Can be re-scraped
```

**Total size: ~2-5 MB** | **Sync time: < 1 min** | **Setup cost: 2-6 hours to re-scrape media**

---

### **2. BALANCED SYNC (Recommended)**

Sync metadata + user themes + partial media cache.

```yaml
sync_path_1: $HOME/ES-DE/

include_1:
  - es_settings.xml
  - es_input.cfg
  - gamelists/          # All .xml files (metadata)
  - collections/        # User playlists
  - custom_systems/     # If exists
  - themes/             # User-downloaded themes

exclude_1:
  - es_log.txt
  - downloaded_media/   # Skip large media cache

sync_path_2: Emulation/tools/downloaded_media/

include_2:
  # OPTIONAL: Sync if < 500MB
  # If > 500MB, skip or compress
  - [all media]

# Or selective:
include_2_selective:
  - PS2/media_*         # Only popular systems
  - N64/media_*
  - GameCube/media_*
```

**Total size: ~50-500 MB** | **Sync time: 1-2 min** | **Setup cost: 30 min to 2 hours**

---

### **3. COMPLETE SYNC (Large Storage Only)**

Sync everything including artwork. Best for users with ample cloud storage.

```yaml
sync_path_1: $HOME/ES-DE/
include_1: [everything except es_log.txt]

sync_path_2: Emulation/tools/downloaded_media/
include_2: [all media]
```

**Total size: ~2-20 GB** | **Sync time: 5-30 min** | **Setup cost: 5-10 min**

---

## Implementation Details

### **ES-DE Application Type**

- **Format:** Native AppImage (NOT Flatpak)
- **Location:** `/home/deck/Applications/ES-DE.AppImage`
- **No special sync needed:** Application itself is not user data

### **Important Paths**

On **Steam Deck** specifically:

- `$HOME` = `/home/deck`
- `Emulation/` = `/home/deck/Emulation/` (if installed to internal) OR `/run/media/mmcblk0p1/Emulation/` (if on SD card)

### **Configuration File Format**

All config files are **XML-based**:

- `es_settings.xml` – Key/value pairs for settings
- `gamelists/*.xml` – Game metadata in standardized format
- `es_systems.xml` – System definitions

**No binary files:** Safe to sync via text-based systems, version control, or cloud sync.

### **Theme Management**

- **Location:** `$HOME/ES-DE/themes/`
- **Format:** Directories containing theme configuration + media files
- **Default theme:** `epic-noir-revisited-es-de` (usually ~20-50 MB)
- **Alternative:** Use ES-DE's built-in **Theme Downloader** on target device (experimental feature in 2.0.1+)

### **Media/Artwork Cache**

- **Location:** `Emulation/tools/downloaded_media/` (external to main config directory)
- **Scrapers:** TheGamesDB (free) and ScreenScraper (requires account for high volume)
- **Regenerable:** Completely optional; can be re-downloaded in bulk via ES-DE's scraper UI
- **Folder structure:** `downloaded_media/[system]/media_[type]/` (screenshots, fanart, cover, etc.)

---

## Recommended Dotfiles Integration

For a dotfiles-based ES-DE sync, use this structure:

```text
~/.dotfiles/steamos/systems/.config/ES-DE/
├── es_settings.xml          # Stow this
├── es_input.cfg             # Stow this (optional)
├── gamelists/               # Stow entire directory
└── themes/                  # Stow if under 100 MB total

# Media cache: Handle separately or skip entirely
# Emulation/tools/downloaded_media/ → Use external sync (Restic, rclone, etc.)
```

**Stow package name suggestion:** `es-de-config`

```sh
stow -t $HOME steamos/systems  # Symlinks ES-DE config to ~/.dotfiles
```

---

## Sync Summary Table

| Component | Size | Sync? | Rationale |
|-----------|------|-------|-----------|
| **es_settings.xml** | 5-20 KB | **MUST** | User preferences |
| **es_input.cfg** | 2-5 KB | **SHOULD** | Controller config |
| **gamelists/*.xml** | 50 KB - 2 MB | **MUST** | Game metadata (irreplaceable effort) |
| **collections/** | 5-100 KB | **SHOULD** | User playlists |
| **custom_systems/es_systems.xml** | 2-10 KB | **CONDITIONAL** | Only if user customized |
| **themes/** | 5-200 MB | **CONDITIONAL** | Large; re-downloadable |
| **downloaded_media/** | 100 MB - 20 GB | **CONDITIONAL** | Massive; regenerable; re-scrapable |
| **es_log.txt** | <1 MB | **NO** | Transient log |

---

## Migration Checklist

When syncing ES-DE config to a new Steam Deck:

- [ ] Verify ES-DE version on target (ideally same major version)
- [ ] Extract `$HOME/ES-DE/` directory from backup/sync
- [ ] Verify symlinks work: `ls -la ~/ES-DE/`
- [ ] Check `es_settings.xml` for scraper paths (may differ if source was SD card, target is internal)
- [ ] If media cache synced, verify `Emulation/tools/downloaded_media/` paths are correct
- [ ] Boot ES-DE and verify themes load (check theme selector in UI Settings)
- [ ] Run scraper on target to fill any media gaps if needed
- [ ] Test controller input using `es_input.cfg`

---

## Notes on Version Compatibility

- **ES-DE 2.x → 3.x:** Migration from `~/.emulationstation/` to `~/ES-DE/`. EmuDeck handles this automatically.
- **Config file compatibility:** Generally forward-compatible, but major version changes may require settings re-export.
- **Gamelist.xml format:** Consistent across versions; safe to restore from backups.

---

## References

- **Official ES-DE User Guide:** <https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE.md>
- **ES-DE FAQ:** <https://gitlab.com/es-de/emulationstation-de/-/blob/master/FAQ.md>
- **EmuDeck ES-DE on SteamOS:** <https://emudeck.github.io/tools/steamos/es-de/>
- **EmuDeck Save Management:** <https://emudeck.github.io/save-management/steamos/save-management/>
- **TheGamesDB (scraper source):** <https://thegamesdb.net/>
- **ScreenScraper (scraper source):** <https://www.screenscraper.fr/>

---

## TL;DR – Quick Answer

**What to sync for portable ES-DE setup:**

1. **MUST:** `$HOME/ES-DE/es_settings.xml` + `gamelists/` (metadata)
2. **SHOULD:** `es_input.cfg` + `collections/` (controller + playlists)
3. **OPTIONAL:** `themes/` (unless < 100 MB)
4. **SKIP:** `downloaded_media/` (regenerable; saves 5-20 GB storage)

**Total essential sync: ~5 MB** | **Balanced sync: ~50-500 MB** | **Full sync: 2-20 GB**

**Re-scrape time if media skipped:** 2-8 hours (depends on collection size + internet speed)
