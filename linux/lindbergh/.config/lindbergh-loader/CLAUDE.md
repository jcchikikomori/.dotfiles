# SEGA Lindbergh Loader Config

Stowed to `~/.config/lindbergh-loader/`. Used by the Lindbergh Loader AppImage to run SEGA Lindbergh arcade games (Initial D 4/5, OutRun 2) — primarily on Steam Deck.

## Layout

- `configs/lindbergh.ini` — base emulator config (display, input mode, region). Reference copy; games load an explicit config via `--config`.
- `configs/<game>.ini` — per-game config override (e.g. `initiald.ini`).
- `controls/default.ini` — fallback control mapping.
- `controls/<game>.ini` — per-game control mapping.

## How games are launched

```sh
"$HOME/AppImages/lindbergh_loader.appimage" \
  --gamepath "$HOME/Games/Lindbergh/<romdir>" \
  --config   "$HOME/.config/lindbergh-loader/configs/<game>.ini" \
  --controls "$HOME/.config/lindbergh-loader/controls/<game>.ini"
```

## Notes for agents

- Hardcoded expectations: dumped games in `~/Games/Lindbergh/`, loader AppImage at `~/AppImages/lindbergh_loader.appimage` (Flatpak/binary builds of the loader were unstable — AppImage only).
- Adding a game: add `configs/<game>.ini` + `controls/<game>.ini` here, then a matching `lindbergh-<game>` launcher (plus `-test` variant) in the `systems` package.
- `.ini` comments in `lindbergh.ini` document each option — keep them when editing.
