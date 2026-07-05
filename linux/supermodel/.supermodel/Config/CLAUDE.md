# Supermodel Config

Two files, two different purposes:

- **`Games.xml`** — ROM set definitions (region/CRC data, hardware stepping, inputs) that Supermodel needs to recognize and load a MAME-style ROM zip. Don't edit unless you're adding/fixing a ROM set.
- **`Supermodel.ini`** — runtime settings. Freely editable.

## How per-game overrides work

`Supermodel.ini` has a `[Global]` section applied to every game, plus optional `[romname]` sections that override `[Global]` for that exact ROM set:

```ini
[scud]
SoundVolume = 50
MusicVolume = 200
```

`romname` must match a `name="..."` attribute in `Games.xml` exactly — find it with:

```sh
grep '<game name=' Games.xml
```

Clone ROMs (`<game name="X" parent="Y">`) do **not** automatically inherit their parent's `Supermodel.ini` section — if a clone needs different settings than `[Global]`, give it its own section.

## WideScreen / WideBackground

Set per game based on genre plus known Supermodel quirks: on for racing/forward-camera rail shooters (no reported issues), off for fighting/sports/light-gun games (documented HUD/goal-post stretching, crosshair misalignment, or fairness issues in versus titles). Follow the existing pattern in the file rather than re-deriving this per game.
