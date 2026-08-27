# Neovim Cheatsheet

Neovim in this repo is configured via a fork of [LazyVim/starter](https://github.com/LazyVim/starter) at [jcchikikomori/dotfiles-lazyvim](https://github.com/jcchikikomori/dotfiles-lazyvim), stowed as the `linux/neovim/.config/nvim` submodule. It becomes your default `$EDITOR`/`$VISUAL` on every platform except Termux (see `stowme.sh`), while Vim stays installed as a zero-dependency fallback.

Leader key is **Space**. Press it and wait — [which-key](https://github.com/folke/which-key.nvim) pops up a menu of every available next key, grouped by category. When in doubt, press Space and read the menu; you rarely need to memorize anything below.

Install with `dotfiles-neovim install` (see `docs/STOW_PACKAGES.md`). First launch downloads plugins automatically — wait for `:Lazy` to finish before doing anything else.

## LSP (language server) navigation

LazyVim wires these up automatically once [mason.nvim](https://github.com/mason-org/mason.nvim) installs a language server for your filetype (`:Mason` to manage servers manually).

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cd` | Line diagnostics |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>cf` | Format buffer |

## Fuzzy finder / picker

LazyVim's default picker is [Snacks](https://github.com/folke/snacks.nvim) (`picker`). All picker prompts share the same navigation: `<C-j>`/`<C-k>` to move, `<Enter>` to select, `<Esc>` to close.

| Key | Action |
| --- | --- |
| `<leader><space>` | Find files (smart: git files if in a repo) |
| `<leader>ff` | Find files |
| `<leader>fg` | Find git files |
| `<leader>fr` | Recent files |
| `<leader>fb` | Open buffers |
| `<leader>sg` | Live grep (search text in project) |
| `<leader>sw` | Search word under cursor |
| `<leader>/` | Grep in open buffers |

## File explorer

Also Snacks-based (`explorer`), a tree view similar to VSCode's sidebar.

| Key | Action |
| --- | --- |
| `<leader>e` | Toggle file explorer (cwd-relative) |
| `<leader>E` | Toggle file explorer (root-relative) |
| Inside explorer: `a` | Create file/directory |
| Inside explorer: `d` | Delete |
| Inside explorer: `r` | Rename |
| Inside explorer: `<Enter>` | Open file / expand directory |

## Which-key (keybinding discovery)

You already met this above — it's the mechanism that makes everything else discoverable.

| Key | Action |
| --- | --- |
| `<leader>` (wait) | Show all top-level keymap groups |
| `<leader>?` | Show buffer-local keymaps |
| `g` (wait) | Show all `g`-prefixed keymaps |
| `z` (wait) | Show all `z`-prefixed keymaps (folds, spelling) |

## DAP debugger

Enabled via this fork's `lua/plugins/extras.lua` (`lazyvim.plugins.extras.dap.core`), which installs [nvim-dap](https://github.com/mfussenegger/nvim-dap) and [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui). Language-specific debug adapters (e.g. `debugpy` for Python, `delve` for Go) install separately via `:Mason` — the core extra provides the UI and keymaps, not every language's adapter.

| Key | Action |
| --- | --- |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue / start debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dt` | Terminate session |
| `<leader>du` | Toggle debugger UI panes |

## Integrated terminal

Also Snacks-based.

| Key | Action |
| --- | --- |
| `<C-/>` or `<C-_>` | Toggle terminal (current window) |
| `<leader>ft` | Toggle terminal (floating) |
| Inside terminal: `<Esc><Esc>` | Return to normal mode without leaving the terminal |

## Git integration

LazyVim ships [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) for in-buffer git status and a Snacks-based lazygit shortcut.

| Key | Action |
| --- | --- |
| `<leader>gg` | Open lazygit (requires `lazygit` installed separately) |
| `]h` / `[h` | Next / previous git hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghb` | Blame line |

## If a keybinding here doesn't match what you see

LazyVim's defaults do drift between releases, and `:LazyExtras` lets you enable more than what's listed here (formatters, linters, additional language packs). This table reflects the plugin set enabled in the pinned fork commit as of the date this file was last updated — when in doubt, trust `<leader>` + which-key over this document.
