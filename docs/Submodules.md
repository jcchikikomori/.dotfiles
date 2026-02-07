# Git Submodules Setup Guide

This dotfiles repository uses **Git submodules** to manage external dependencies, particularly for VS Code user prompts and configurations.

## What are Git Submodules?

Git submodules allow you to include external Git repositories within your project. They're stored as separate repositories but referenced from a parent repository, maintaining their own commit history while being tracked in the parent repo.

## Current Submodules

| Path | Repository | Purpose |
|------|------------|---------|
| `linux/vscode/.config/Code/User/prompts` | [impromptu](https://github.com/jcchikikomori/impromptu) | VS Code custom prompts and instructions |

## Initial Clone with Submodules

When cloning this repository for the first time, use the `--recurse-submodules` flag to automatically fetch all submodules:

```bash
git clone --recurse-submodules https://github.com/jcchikikomori/dotfiles.git ~/.dotfiles
```

Alternatively, if you've already cloned without submodules:

```bash
cd ~/.dotfiles
git submodule update --init --recursive
```

## Working with Submodules

### Update All Submodules to Latest Remote

```bash
git submodule update --remote
```

This pulls the latest commits from the default branch of each submodule's remote repository.

### Update a Specific Submodule

```bash
git submodule update --remote linux/vscode/.config/Code/User/prompts
```

### Checking Submodule Status

```bash
git submodule status
```

Output example:
```
 a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6 linux/vscode/.config/Code/User/prompts (heads/main)
```

The commit hash shows the current pinned version; this is intentional to ensure consistent behavior across installations.

## Adding a New Submodule

To add a new external repository as a submodule:

```bash
git submodule add <repository-url> <path>
```

Example:
```bash
git submodule add https://github.com/user/repo linux/config/subdir
```

Then commit the changes:
```bash
git add .gitmodules linux/config/subdir
git commit -m "Add submodule: repository description"
```

## Removing a Submodule

If you need to remove a submodule:

```bash
git submodule deinit -f linux/vscode/.config/Code/User/prompts
git rm -f linux/vscode/.config/Code/User/prompts
git commit -m "Remove submodule: impromptu"
```

## Troubleshooting

### Submodule shows "detached HEAD"

This is normal. Submodules are pinned to specific commits for reproducibility. To update to the latest:

```bash
cd linux/vscode/.config/Code/User/prompts
git checkout main  # or your desired branch
git pull
cd ../../../..
git add linux/vscode/.config/Code/User/prompts
git commit -m "Update impromptu submodule"
```

### Submodule directory is empty

Run:
```bash
git submodule update --init --recursive
```

### Changes to submodule not showing up

Submodules track specific commits. To see changes:
```bash
cd path/to/submodule
git fetch
git merge origin/main  # or desired branch
```

Then from the parent repo:
```bash
git add path/to/submodule
git commit -m "Update submodule to latest"
```

## Integration with dotfiles-post-setup

The `dotfiles-post-setup` script automatically handles:
1. Cloning via `start.sh` (which calls `git clone --recursive`)
2. Symlinking configurations from submodules to appropriate `$HOME` locations

No manual submodule management is required during the normal setup flow.

## CI/CD Considerations

GitHub Actions workflows automatically handle submodule cloning. Ensure workflow YAML includes:

```yaml
- name: Checkout with submodules
  uses: actions/checkout@v4
  with:
    submodules: recursive
```

## References

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [GitHub Submodules Guide](https://docs.github.com/en/repositories/working-with-submodules)
