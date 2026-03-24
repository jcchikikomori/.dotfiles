# Git Commit Guard - Additional Safeguards

This document explains the additional defensive measures added to prevent accidental `git commit` operations in opencode sessions.

## Why This Matters

This machine requires **GPG-signed commits**, but opencode sessions have **no TTY access**. This causes GPG to fail with:
```
gpg: cannot open '/dev/tty': No such device or address
```

We now have **three layers of defense** to prevent this issue:

## Layer 1: Hard-Deny Permission Rules (opencode.jsonc)

The permission system **denies** specific git commands:

```jsonc
"bash": {
  "git commit *": "deny",
  "git commit": "deny",
  "git push *": "deny",
  "git push": "deny",
  "git reset --hard *": "deny",
  "git revert *": "ask",
  "sudo *": "ask"
}
```

If an agent tries to run `git commit`, it will be **immediately blocked** by the permission system.

### Additional Safeguards Added
- `git reset --hard *` — Prevents destructive undo operations
- `git revert *` — Requires user confirmation before reverting
- `sudo *` — Requires user confirmation for any sudo command

## Layer 2: Git Commit Guard Plugin (git-commit-guard.ts)

A custom TypeScript plugin that intercepts bash commands **before execution** and blocks any `git commit` attempt with a clear error message:

```
🚫 BLOCKED: git commit is not allowed in opencode sessions.

REASON: This machine requires GPG-signed commits, but opencode sessions have no TTY access.
```

The plugin also logs allowed git operations for debugging.

## Layer 3: Agent Instructions (AGENTS.md)

The global agent instructions explicitly state:
- **MANDATORY:** Load the `git` skill before any git operation
- Clear explanation of the GPG+TTY limitation
- List of allowed vs. blocked operations

## Workflow Recommendations

### ✅ Allowed in opencode:
```bash
git add <files>
git status
git diff
git log --oneline
git stash
git branch
git checkout <branch>
git merge <branch>
git rebase <branch>
```

### ❌ Do in your local terminal:
```bash
git commit -m "message"
git push
git reset --hard
```

## Testing the Safeguards

To verify the safeguards are working, try running:
```bash
git commit -m "test"
```

You should see:
1. Permission system blocks it with "deny"
2. Plugin logs the attempted operation
3. Clear error message explaining why

## Files Changed

| File | Change |
|------|--------|
| `linux/opencode/.config/opencode/opencode.jsonc` | Added `git-commit-guard` plugin + enhanced permission rules |
| `linux/opencode/.config/opencode/plugins/git-commit-guard.ts` | New plugin file |
| `linux/opencode/.config/opencode/AGENTS.md` | Enhanced git skill loading instructions |

## Plugin Architecture

The plugin uses the opencode Plugin API:

```typescript
export const GitCommitGuardPlugin: Plugin = async ({ client }) => {
  return {
    "tool.execute.before": async (input) => {
      // Intercepts commands BEFORE execution
      // Throws error if git commit detected
    }
  }
}
```

This is a **defense-in-depth** approach — multiple layers ensure no git commit can slip through.
