# Plasma Baseline Templates

This directory stores baseline KDE Plasma config templates for fresh Linux installs.

Important:

- This directory is intentionally outside `linux/` and is not stowed.
- Apply templates using `dotfiles-plasma-baseline` to copy files into `$HOME`.
- Runtime changes in KDE (themes, wallpapers, panel edits, app rules) stay local and no longer pollute this repository.

Included template targets:

- `~/.config/kdeglobals`
- `~/.config/kwinrulesrc`
- `~/.config/plasmarc`
- `~/.config/plasmashellrc`
- `~/.local/share/kwin/scripts/` (Plasma 5/6 compatibility path)
- `~/.local/share/kservices5/` (Plasma 5 compatibility path)
