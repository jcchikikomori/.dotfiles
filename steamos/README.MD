# Setup for Steam Deck

## Instructions

Proceed to the normal setup by executing `setup.sh`

## Copyparty (systemd user service)

Copyparty can run as a `systemctl --user` service and works in Desktop Mode and Gaming Mode.

1. Run `dotfiles-post-setup` and choose `Copyparty file server`, or run `dotfiles-copyparty install`
2. Start once: `dotfiles-copyparty start`
3. Enable at login: `dotfiles-copyparty startup`
4. Check logs: `dotfiles-copyparty logs`
5. Setup auth wizard (username/password): `dotfiles-copyparty setup-auth`

Default shared paths:

- `$HOME/Downloads`
- `$HOME/Pictures`
- `$HOME/Videos`

Auth credentials are stored in `~/.config/copyparty/copyparty.env` (not in git-tracked files).
