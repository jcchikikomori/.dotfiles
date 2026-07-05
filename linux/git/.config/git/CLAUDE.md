# Git Package

The `git` stow package ships three files into `$HOME`: `.gitconfig`, `.gitignore`, and `.pre-commit-config.yaml`. This note lives in `~/.config/git/` because the package root maps directly to `$HOME`.

## Identity switching (`.gitconfig`)

Two named identities are defined as `[user "work"]` and `[user "personal"]` sections, each with its own noreply email and GPG signing key. Switch the active identity per-repo with the alias:

```sh
git identity work      # copies user.work.* into user.name/email/signingkey
git identity personal
```

Default (top-level `[user]`) is the personal identity.

## Signing

- `commit.gpgsign = true` — all commits are GPG-signed, everywhere. Do not disable it to "fix" a failing commit; fix the GPG/pinentry setup instead (see the `gpg` package notes in `~/.gnupg/CLAUDE.md`).
- `git lsa` alias shows the log with signatures for verification.

## Other conventions baked in

- `pull.rebase = true` — pulls rebase, never merge.
- `credential.helper` points at the Windows Git Credential Manager path — WSL-specific; harmless elsewhere but expect it to be a no-op outside WSL.
- Git LFS filters are pre-configured and `required`.
- `~/.pre-commit-config.yaml` is the fallback pre-commit config (commitizen conventional-commit checks, whitespace/yaml/json hygiene, black) for repos without their own.

## Notes for agents

- Editing `~/.gitconfig` edits this repo's `linux/git/.gitconfig` through the stow symlink — treat it as versioned config, not a scratch file.
- Never change signing keys or identity emails without explicit user request.
