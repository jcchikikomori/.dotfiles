# Plasma User Config Package

This stow package is focused on KDE Plasma 6 user configuration, while keeping compatibility paths used by Plasma 5.

Included targets:

- `~/.config/kwinrulesrc` for KWin window rules
- `~/.local/share/kwin/scripts/` for user/manual KWin scripts (Plasma 5/6)
- `~/.local/share/kservices5/` compatibility path used by some Plasma 5 script metadata

Related package:

- `wireplumber` remains a separate stow package for desktop-environment agnostic audio config.

Notes:

- Place custom KWin scripts inside `linux/plasma/.local/share/kwin/scripts/`.
- If a Plasma 5 script requires desktop metadata, add it under `linux/plasma/.local/share/kservices5/`.
