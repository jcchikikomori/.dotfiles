# ES-DE Sync Quick Reference Card

**Print this or bookmark for rapid reference during implementation.**

---

## Directory Map

```text
Essential for Sync          Location                          Size        Sync?
─────────────────────────────────────────────────────────────────────────────
Settings                   $HOME/ES-DE/es_settings.xml       5-20 KB     ✓ MUST
Controller Config           $HOME/ES-DE/es_input.cfg          2-5 KB      ✓ SHOULD
Game Metadata               $HOME/ES-DE/gamelists/            50KB-2MB    ✓ MUST
User Playlists              $HOME/ES-DE/collections/          1-100 KB    ✓ SHOULD
Custom Systems              $HOME/ES-DE/custom_systems/       2-10 KB     ✓ IF EXISTS
UI Themes                   $HOME/ES-DE/themes/               5-200 MB    ? OPTIONAL
Scraped Artwork             Emulation/tools/downloaded_media/ 100MB-20GB  ✗ SKIP
Logs (transient)            $HOME/ES-DE/es_log.txt            <1 MB       ✗ NO
```

---

## Sync Size Predictions

| Collection Size | Metadata | Themes | Media  | Total w/ Media | w/o Media |
| --------------- | -------- | ------ | ------ | -------------- | --------- |
| 50 games        | 50 KB    | 10 MB  | 100 MB | 110 MB         | 10 MB     |
| 200 games       | 300 KB   | 50 MB  | 500 MB | 550 MB         | 50 MB     |
| 1000 games      | 2 MB     | 100 MB | 5 GB   | 5.1 GB         | 102 MB    |
| 5000 games      | 10 MB    | 200 MB | 20 GB  | 20.2 GB        | 210 MB    |

---

## One-Liner Commands

### Backup Current ES-DE

```bash
cp -r ~/ES-DE ~/Backups/ES-DE-$(date +%Y%m%d)
```

### Copy to Dotfiles (Metadata Only)

```bash
mkdir -p ~/.dotfiles/steamos/systems/.config/ES-DE && \
cp ~/ES-DE/es_settings.xml ~/.dotfiles/steamos/systems/.config/ES-DE/ && \
cp ~/ES-DE/es_input.cfg ~/.dotfiles/steamos/systems/.config/ES-DE/ 2>/dev/null && \
cp -r ~/ES-DE/gamelists ~/.dotfiles/steamos/systems/.config/ES-DE/ && \
cp -r ~/ES-DE/collections ~/.dotfiles/steamos/systems/.config/ES-DE/
```

### Test Stow Dry-Run

```bash
cd ~/.dotfiles && stow -n -v -t $HOME steamos/systems
```

### Apply Stow

```bash
cd ~/.dotfiles && stow -t $HOME steamos/systems
```

### Verify Symlinks

```bash
ls -la ~/.config/ES-DE/ && file ~/.config/ES-DE/*
```

### Check Media Cache Size

```bash
du -sh ~/Emulation/tools/downloaded_media/
```

### Show All ES-DE File Sizes

```bash
du -sh ~/ES-DE/* && du -sh ~/ES-DE/.??* 2>/dev/null
```

---

## Implementation Checklist

- [ ] **BACKUP:** `cp -r ~/ES-DE ~/Backups/ES-DE-backup`
- [ ] **CREATE:** `mkdir -p ~/.dotfiles/steamos/systems/.config/ES-DE`
- [ ] **COPY:** Essential files to `~/.dotfiles/steamos/systems/.config/ES-DE/`
  - [ ] `es_settings.xml`
  - [ ] `es_input.cfg` (optional)
  - [ ] `gamelists/` (entire directory)
  - [ ] `collections/` (entire directory)
- [ ] **UPDATE:** Add `steamos/systems` to `~/.dotfiles/stowme.sh`
- [ ] **TEST:** `stow -n -t $HOME steamos/systems` (dry run)
- [ ] **APPLY:** `stow -t $HOME steamos/systems`
- [ ] **VERIFY:** `ls -la ~/.config/ES-DE/` (all should be symlinks)
- [ ] **BOOT:** Launch ES-DE via `/home/deck/Applications/ES-DE.AppImage`
- [ ] **VALIDATE:** Check settings loaded, controller works, games display
- [ ] **GIT:** `git add steamos/systems/.config/ES-DE/`
- [ ] **COMMIT:** `git commit -m "feat: add ES-DE configuration"`
- [ ] **PUSH:** `git push origin main` (after user approval)

---

## Conflict Resolution

**If stow fails with "target already exists":**

```bash
# Option 1: Move existing to backup
mv ~/.config/ES-DE ~/.config/ES-DE.bak

# Option 2: Show what's in existing (if not symlink yet)
ls -la ~/.config/ES-DE/

# Option 3: Force stow if safe
stow -t $HOME --adopt steamos/systems  # ⚠️ Use with caution
```

---

## Rollback

If something breaks:

```bash
# 1. Undo stow
stow -D -t $HOME steamos/systems

# 2. Restore backup
cp -r ~/Backups/ES-DE-backup/* ~/.config/ES-DE/

# 3. Verify ES-DE boots
/home/deck/Applications/ES-DE.AppImage
```

---

## Re-Scrape Media (If Skipped)

On target device after stowing:

1. Open ES-DE
2. Press **START** → **SCRAPE**
3. Select **SELECT SYSTEMS** → Check all systems
4. Press **BACK** → Press **START** to begin scraping
5. Wait 2-8 hours (depending on collection size)

---

## Media Cache Alternatives

| Option                 | Storage Used | Time to Setup | Pros                                    | Cons                         |
| ---------------------- | ------------ | ------------- | --------------------------------------- | ---------------------------- |
| **Skip (Recommended)** | 50-100 MB    | 5 min         | Dotfiles stays small; media regenerable | Requires re-scrape (2-8 hrs) |
| **Restic Backup**      | 100 MB-20 GB | 30 min        | Portable; can restore selectively       | Requires backup tool setup   |
| **Rclone Cloud**       | 100 MB-20 GB | 1-2 hrs       | Accessible anywhere                     | Depends on cloud speed/quota |
| **Compress & Store**   | 50-200 MB    | 1 hour        | Portable; can extract if needed         | Manual management            |

---

## ES-DE Settings Worth Backing Up

Key settings in `es_settings.xml`:

- **ThemeSet:** Your chosen theme name
- **Language:** UI language preference
- **ScreensaverType / ScreensaverBehaviour:** Screensaver config
- **CollectionSystemsAuto / CollectionSystemsCustom:** User collections
- **Scrapers & Preferences:** Which scraper sources to use
- **FavoritesOnly / HiddenGamesFilter:** View preferences

All preserved by syncing `es_settings.xml`. ✓

---

## Troubleshooting

| Problem                             | Cause                       | Solution                                                |
| ----------------------------------- | --------------------------- | ------------------------------------------------------- |
| Stow fails: "target already exists" | Old ES-DE dir not symlinked | `mv ~/.config/ES-DE ~/.config/ES-DE.bak` then retry     |
| ES-DE won't launch after stow       | Broken symlink to config    | Check symlink: `file ~/.config/ES-DE/`                  |
| Settings don't load                 | Wrong config path           | Verify: `cat ~/.config/ES-DE/es_settings.xml \| head`   |
| Gamelists empty                     | Symlink broken              | `ls -la ~/.config/ES-DE/gamelists/` should show folders |
| Controller doesn't work             | Missing es_input.cfg        | Copy it: `cp ~/ES-DE/es_input.cfg ~/.dotfiles/.../`     |
| Media artwork missing               | Skipped in sync             | Run scraper in ES-DE or restore media backup            |

---

## File Format Reference

All ES-DE config is **XML**:

```xml
<!-- es_settings.xml: Key-value pairs -->
<bool name="ParseGamelistOnly" value="true" />
<string name="ThemeSet" value="epic-noir-revisited-es-de" />

<!-- gamelist.xml: Game metadata per system -->
<game>
  <path>./Metroid Prime.iso</path>
  <name>Metroid Prime</name>
  <desc>First-person adventure</desc>
  <rating>0.9</rating>
  <releasedate>20021118</releasedate>
</game>

<!-- es_systems.xml: Custom system definitions -->
<system>
  <name>snes</name>
  <fullname>Super Nintendo Entertainment System</fullname>
  <path>~/ROMs/snes</path>
  <extension>.smc .sfc</extension>
  <command>retroarch %ROM%</command>
</system>
```

All text-based → safe for version control. ✓

---

## Post-Migration Validation

After stowing on new device, run:

```bash
# 1. Verify symlinks exist
test -L ~/.config/ES-DE/es_settings.xml && echo "✓ Config symlinked"

# 2. Verify content readable
test -r ~/.config/ES-DE/es_settings.xml && echo "✓ Config readable"

# 3. Count gamelists
ls ~/.config/ES-DE/gamelists/*/gamelist.xml 2>/dev/null | wc -l | tr -d '\n' && echo " gamelists found"

# 4. Boot ES-DE and check logs
/home/deck/Applications/ES-DE.AppImage &
sleep 5
tail -20 ~/ES-DE/es_log.txt

# 5. Check no errors in log
grep -i "error\|critical\|fatal" ~/ES-DE/es_log.txt || echo "✓ No errors"
```

---

## Reference Links

- **Full Sync Strategy:** See `ES-DE_sync_structure.md`
- **Implementation Guide:** See `ES-DE_dotfiles_implementation.md`
- **Official User Guide:** <https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE.md>
- **EmuDeck Wiki:** <https://emudeck.github.io/tools/steamos/es-de/>

---

## Last Updated

March 21, 2025 | Based on EmuDeck official documentation
ES-DE version support: 2.0+ through 3.x
