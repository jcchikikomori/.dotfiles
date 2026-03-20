# Global Agent Instructions

These rules apply across all opencode sessions on this machine.
Edit this file via `dotfiles-opencode-wizard` → Edit Instructions, or directly with your editor.

## Existing instructions from dotfiles

- Look up for other existing instructions on either `$HOME/.config/Code/User/prompts` or `$HOME/.dotfiles/linux/vscode/.config/Code/User/prompts` directory, then inherit them or use them.

## Git Rules

- **Never run `git commit` or `git push`** — these are hard-denied in `opencode.jsonc`.
- The reason: this machine requires **GPG-signed commits**, and opencode sessions have no TTY access, so GPG always fails with `gpg: cannot open '/dev/tty': No such device or address`.
- Your job is to **prepare and stage changes only** (`git add`). The user will commit and push manually in their own terminal where GPG + TTY work.
- `git stash`, `git diff`, `git status`, `git log`, `git add`, and read-only git commands are all fine.
- For revert/undo, use `git blame` to identify changes and reduce mistakes.
- Fetch the current repository first before doing any changes. If there is an ongoing change from upstream, ask if a merge/rebase is needed.

## MCP Hints

- When you need up-to-date library docs, use `context7` tools.
- When you need GitHub repo/PR/issue context, use `github` tools (requires token).
