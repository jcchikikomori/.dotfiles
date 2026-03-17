# Git Cheatsheet

Quick reference for day-to-day Git usage in this dotfiles repo.

## Setup and Identity

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

## Start and Clone

```bash
git clone <repo-url>
git init
git status
```

## Daily Workflow

```bash
git status
git add <file>
git add .
git commit -m "message"
git push origin <branch>
git pull origin <branch>
```

## Branching

```bash
git branch
git branch -a
git switch <branch>
git switch -c <new-branch>
git checkout <branch>          # older alternative
git checkout -b <new-branch>   # older alternative
git merge <branch>
git rebase <branch>
```

## Inspect History

```bash
git log
git log --oneline --graph --decorate --all
git show <commit>
git diff
git diff --staged
git blame <file>
```

## Stash and Tags

```bash
git stash
git stash list
git stash pop
git tag
git tag -a v1.0.0 -m "release"
git push --tags
```

## Undo and Recovery

```bash
git restore <file>
git restore --staged <file>
git revert <commit>
git reset --soft HEAD~1
git reset --mixed HEAD~1
git reflog
```

## Remote and Sync

```bash
git remote -v
git fetch --all --prune
git pull --rebase
git push -u origin <branch>
```

## Useful One-Liners

```bash
git log --since="2 weeks ago" --oneline --author="yourname"
git shortlog -sn
git clean -fdn    # dry-run for untracked cleanup
```

## Zsh and Bash Aliases (Repo Context)

### Existing Custom Alias in This Repo

Defined in `linux/zsh/.zalias`:

```bash
alias hackerman="tmuxp load default"
alias gpall="git remote | xargs -I {} git push {}"
```

### Where to Add New Aliases

```text
zsh:  linux/zsh/.zalias
bash: linux/bash/.bashrc.d/ (create a file like 05-aliases)
```

Note: this repo currently has no dedicated custom Bash alias file.

## Oh-My-Zsh Git Aliases

This repo enables the `git` plugin in `linux/zsh/.zshrc`, so common Oh-My-Zsh aliases are available (depends on your installed Oh-My-Zsh version):

```bash
g='git'
ga='git add'
gaa='git add --all'
gb='git branch'
gco='git checkout'
gcb='git checkout -b'
gcmsg='git commit -m'
gst='git status'
gd='git diff'
gl='git pull'
gp='git push'
glog='git log --oneline --decorate --graph'
```

To verify currently loaded aliases in your shell:

```bash
alias | grep '^g'
type gco
```

## Quick Safe Workflow for This Repo

```bash
git status
git add <files>
git commit -m "<clear message>"
git push origin <your-branch>
```
