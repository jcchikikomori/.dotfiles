# devtools-clean-branch

Rebuild a polluted PR branch by cherry-picking selected commits on top of a
clean base branch.

Part of the `systems` stow package under `org.jcchikikomori.devtools` —
available on all supported platforms
(Debian, Ubuntu, Arch, SteamOS, RHEL, Termux, macOS).

---

## Why

A PR branch can become "polluted" when it accidentally contains unrelated
commits (merge commits from the wrong branch, stray fixups, local experiments,
etc.).  Rather than rebasing interactively or hunting through the reflog,
`devtools-clean-branch` lets you:

1. Inspect which commits are unique to your branch.
2. Choose exactly which ones to keep.
3. Rebuild the branch cleanly on top of the target.

A backup branch is always created before any history rewrite.

---

## Synopsis

```sh
devtools-clean-branch [OPTIONS] TARGET_BRANCH WORK_BRANCH
```

| Argument | Description |
|---|---|
| `TARGET_BRANCH` | The clean base (e.g. `main`, `develop`) |
| `WORK_BRANCH` | The polluted branch to rebuild |

---

## Options

| Flag | Default | Description |
|---|---|---|
| `-r REMOTE` | `origin` | Remote name |
| `-c COMMITS` | — | Comma/space-separated hashes or ranges (skip interactive) |
| `-C` | off | **Create commits** (opt-in). By default only staged changes are produced. Pass `-C` to create actual commits per cherry-pick. |
| `-n` | off | Dry-run: print plan only, no mutations |
| `-f` | off | Enable force-push prompt after rebuild (only meaningful with `-C`) |
| `-h` | — | Show help and exit |

---

## Default behavior: no-commit mode

**By default** the tool applies cherry-picked changes and stages them **without
creating commits** — equivalent to running `git cherry-pick -n` for each
selected commit.  This lets you:

- Review the staged diff (`git diff --staged`) before committing.
- Squash, reorder, or amend before the history is written.
- Combine multiple cherry-picks into a single clean commit.

After the tool exits you are left with staged changes on `WORK_BRANCH`. Commit
and push when ready:

```sh
git checkout WORK_BRANCH
git diff --staged          # review
git commit -m "your message"
git push --force-with-lease origin WORK_BRANCH
```

---

## Opt-in commit mode (`-C`)

Pass `-C` to restore the previous behavior: each cherry-picked commit is
applied **and** committed immediately (one commit per cherry-pick).

```sh
devtools-clean-branch -C main feature/my-polluted-pr
```

---

## Conflict resolution (interactive pause)

When a cherry-pick encounters a conflict the script **pauses** and prompts you
instead of aborting immediately. You are given three choices:

| Choice | Key | What happens |
|---|---|---|
| **continue** | `c` | Resolve conflicts in another terminal, stage files, return and press `c`. The script runs `git cherry-pick --continue` (commit mode) or simply proceeds to the next commit (no-commit mode). |
| **skip** | `s` | Discard this conflicted commit and continue with the remaining ones. |
| **abort** | `a` | Abort the entire cherry-pick sequence and exit. The index/worktree is cleaned up. Your originals are safe in the backup branch. |

### Conflict resolution workflow

#### Commit mode (`-C`)

```
CONFLICT while cherry-picking: abc1234 Add new API endpoint

The cherry-pick is paused. To resolve:
  1. Open a NEW terminal and check out this branch.
  2. Edit the conflicted files (look for <<<<<<< markers).
  3. Stage your resolutions:  git add <files>
  4. Return here and choose [c]ontinue.
     The script will run: git cherry-pick --continue

Choices:
  [c] continue — conflicts resolved & staged, proceed
  [s] skip     — discard this commit and continue with the rest
  [a] abort    — abort the entire operation and exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Action [c/s/a]:
```

Steps when you choose `continue` in commit mode:

1. In a second terminal: `git checkout WORK_BRANCH`
2. Fix conflict markers in the affected files.
3. `git add <resolved-files>`
4. Back in the first terminal: press `c` + Enter.
5. The script runs `git cherry-pick --continue` and proceeds.

#### No-commit mode (default)

In no-commit mode `git cherry-pick -n` does **not** leave a cherry-pick
session in progress (no `CHERRY_PICK_HEAD`). Conflicting files are written to
the worktree with conflict markers and partially staged. The prompt explains
this:

```
CONFLICT while cherry-picking: abc1234 Add new API endpoint

The cherry-pick -n failed (index may be partially applied).
To resolve:
  1. Open a NEW terminal and check out this branch.
  2. Edit the conflicted files (look for <<<<<<< markers).
  3. Stage your resolutions:  git add <files>
  4. Return here and choose [c]ontinue.
     The script will proceed to the next commit.
  Note: In no-commit mode, git cherry-pick --continue is NOT
  used; you stage manually and the script moves on.
```

Steps when you choose `continue` in no-commit mode:

1. In a second terminal: `git checkout WORK_BRANCH`
2. Fix conflict markers.
3. `git add <resolved-files>` (do **not** run `git cherry-pick --continue`).
4. Back in the first terminal: press `c` + Enter.
5. The script proceeds to the next commit.

### Skip example

```
Action [c/s/a]: s
  Skipping commit abc1234 Add new API endpoint — resetting conflicted changes ...
  Skipped.
  Cherry-picking (no-commit / stage only): def5678 Wire up tests
```

### Abort example

```
Action [c/s/a]: a
  Aborting cherry-pick sequence — resetting index and worktree ...
WARNING: Cherry-pick sequence aborted.
WARNING: Branch 'feature/my-polluted-pr' may be in a partially-applied state.
WARNING: Your original commits are safe in backup branch: feature/my-polluted-pr-backup-20260325120000
WARNING: To restore the original branch:
WARNING:   git checkout feature/my-polluted-pr
WARNING:   git reset --hard feature/my-polluted-pr-backup-20260325120000
```

---

## Usage examples

### Interactive — pick commits one by one (no-commit mode, default)

```sh
# Switch off the branch you want to clean first
git checkout main

devtools-clean-branch main feature/my-polluted-pr
```

The script lists commits unique to `feature/my-polluted-pr` with numbers:

```
  [1] a1b2c3d Fix typo in README
  [2] 4e5f6a7 Add new API endpoint
  [3] 8b9c0d1 WIP: debugging cruft — DO NOT MERGE
  [4] ef12345 Wire up tests

Your selection:
```

Enter a selection such as `1,2,4` or `1-2,4` or `all`.

After completion the selected changes are **staged but not committed** on
`feature/my-polluted-pr`.

---

### Interactive — create commits per cherry-pick (`-C`)

```sh
devtools-clean-branch -C main feature/my-polluted-pr
```

Commits are created automatically, one per selected cherry-pick.

---

### Non-interactive — specify commits with `-c`

```sh
# No-commit mode (default) — staged changes only
devtools-clean-branch -c "a1b2c3d,4e5f6a7,ef12345" main feature/my-polluted-pr

# Create commits
devtools-clean-branch -C -c "a1b2c3d,4e5f6a7,ef12345" main feature/my-polluted-pr

# By range (git log range notation, oldest-first)
devtools-clean-branch -c "a1b2c3d..ef12345" main feature/my-polluted-pr
```

---

### Dry-run first (always a good idea)

```sh
devtools-clean-branch -n main feature/my-polluted-pr
# or with explicit commits:
devtools-clean-branch -n -c "a1b2c3d,ef12345" main feature/my-polluted-pr
```

Output example (default no-commit mode):

```
  Target  : main (abc1234...)
  Working : feature/my-polluted-pr  (def5678...)
  Remote  : origin
  Mode    : no-commit mode (staged changes only — default)
  [DRY-RUN mode — no mutations will be made]

  [DRY-RUN] Would create backup branch: feature/my-polluted-pr-backup-20260325120000
  [DRY-RUN] Would reset 'feature/my-polluted-pr' to 'main'
  [DRY-RUN] Would cherry-pick -n (staged changes only, no commits):
    a1b2c3d Fix typo in README
    ef12345 Wire up tests
  [DRY-RUN] No-commit mode: after real run, review staged changes then:
  [DRY-RUN]   git commit  (or git commit --amend, etc.)
  [DRY-RUN]   git push --force-with-lease origin feature/my-polluted-pr
  Dry-run complete. No changes made.
```

---

### With force-push (requires `-C` + double confirmation)

```sh
devtools-clean-branch -C -f main feature/my-polluted-pr
```

After the cherry-pick succeeds you will be asked **a second time** whether to
force-push. The push uses `--force-with-lease` to avoid overwriting unexpected
remote changes.

> **Note:** `-f` has no effect in no-commit mode (the default). You must
> commit manually before pushing in that case.

---

### Custom remote

```sh
devtools-clean-branch -r upstream main feature/my-polluted-pr
```

---

## Safety model

| Action | When |
|---|---|
| Creates backup branch `WORK_BRANCH-backup-<timestamp>` | Always, before any mutation |
| Warns about history rewrite | Always |
| Requires explicit `y` confirmation | Before resetting the branch |
| Pauses on conflict with continue/skip/abort prompt | On each conflicted cherry-pick |
| Uses `--force-with-lease` on push | When `-C -f` flags are used |
| Requires a second `y` confirmation for force-push | Always, regardless of `-f` |

**You can always restore the original state:**

```sh
git branch -f feature/my-polluted-pr feature/my-polluted-pr-backup-20260325120000
# or after an abort:
git checkout feature/my-polluted-pr
git reset --hard feature/my-polluted-pr-backup-20260325120000
```

---

## Behavior summary

| Mode | Flag | Commits created? | Post-run state |
|---|---|---|---|
| **No-commit (default)** | _(none)_ | No | Changes staged on `WORK_BRANCH`; commit manually |
| Create-commit | `-C` | Yes | `WORK_BRANCH` has new commits; push with `--force-with-lease` |

---

## Caveats / Limitations

- **Must not be on `WORK_BRANCH`** when running — the script exits early if the
  branch is currently checked out (to avoid index/worktree confusion).
- **Cherry-pick conflicts** now pause the sequence and prompt for
  `continue / skip / abort` instead of aborting immediately.
  - In **commit mode** (`-C`), continuation uses `git cherry-pick --continue`.
  - In **no-commit mode** (default), `git cherry-pick --continue` is **not**
    applicable — you stage your resolutions manually and choose `continue` to
    let the script move on to the next commit.
- **Force-push only applies in create-commit mode** (`-C -f`). In no-commit
  mode you commit manually and push yourself.
- **Termux**: interactive `/dev/tty` prompts work normally in the Termux shell;
  the script is fully POSIX-compatible.
- **macOS**: uses `date +%Y%m%d%H%M%S` which is portable; no GNU `date`
  extensions required.
- The script does **not** fetch from the remote before operating — run
  `git fetch` first if you need the latest state of `TARGET_BRANCH`.

---

## Location in repo

```
linux/systems/.local/bin/org.jcchikikomori.devtools/bin/devtools-clean-branch
darwin/systems/.local/bin/org.jcchikikomori.devtools/bin/devtools-clean-branch
```

Stowed to `$HOME/.local/bin/org.jcchikikomori.devtools/bin/` by the `systems`
package.
