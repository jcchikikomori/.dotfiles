# GnuPG Package

Stowed to `~/.gnupg/`. Two small files that exist for one purpose: make GPG commit signing work in terminals, WSL, and headless sessions.

- `gpg.conf` — `use-agent` + `pinentry-mode loopback` (passphrase goes through the agent loopback instead of a GUI pinentry popup).
- `gpg-agent.conf` — `pinentry-program /usr/bin/pinentry-tty` + `allow-loopback-pinentry` (required for the loopback mode above to be accepted by the agent).

## Notes for agents

- These settings pair with `commit.gpgsign = true` in the `git` package — if commit signing breaks, check this pinentry chain first (`gpg-connect-agent reloadagent /bye` after edits).
- `pinentry-tty` requires a usable TTY; GUI-only contexts need a different pinentry program — change `pinentry-program`, don't remove loopback support.
- Keyrings, private keys, and trust databases are **not** part of this package — only these two config files are versioned. Never add key material here.
