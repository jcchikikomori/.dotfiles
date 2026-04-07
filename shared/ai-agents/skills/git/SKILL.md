---
name: git
description: Git workflow rules for this machine. GPG-signed commits required, opencode sessions cannot commit. Focus on staging (git add), reading, and branch management.
---

# Git Rules

- **Never run `git commit` or `git push`** — these are hard-denied in `opencode.jsonc`.
- The reason: this machine requires **GPG-signed commits**, and opencode sessions have no TTY access, so GPG always fails with `gpg: cannot open '/dev/tty': No such device or address`.
- Your job is to **prepare and stage changes only** (`git add`). The user will commit and push manually in their own terminal where GPG + TTY work.
- `git stash`, `git diff`, `git status`, `git log`, `git add`, and read-only git commands are all fine.
- For revert/undo, use `git blame` to identify changes and reduce mistakes.
- Fetch the current repository first before doing any changes. If there is an ongoing change from upstream, ask if a merge/rebase is needed.
