# Flatpak Autostart Entries

`.desktop` files here are stowed to `~/.config/autostart/` and launched by the desktop environment at login. Each one starts a Flatpak app (Bitwarden, Discord, Vesktop).

## Adding a new autostart entry

1. Name the file after the Flatpak app ID: `<app.id>.desktop` (e.g. `com.bitwarden.desktop.desktop`).
2. Minimum required keys:

```ini
[Desktop Entry]
Exec=flatpak run <app.id>
Name=<app.id>
Type=Application
X-Flatpak=<app.id>
```

1. Prefer copying the app's own desktop entry from `/var/lib/flatpak/exports/share/applications/<app.id>.desktop` and adding flags like `--start-minimized` to `Exec` — see the Discord/Vesktop entries for the full-metadata pattern.

## Notes for agents

- These entries assume the app is already installed via Flatpak; installation itself is not handled by this package.
- Chat apps here intentionally use `--start-minimized` so login isn't interrupted.
- Removing a file only stops autostart; it does not uninstall the app.
