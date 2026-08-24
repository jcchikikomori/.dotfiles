# Ruby via Homebrew (`RUBY_INSTALL_METHOD=homebrew`)

## What this is

`dotfiles-ruby` normally installs Ruby (and rbenv) via the distro's own
package manager (`apt`, `dnf`, `pacman`). On Debian/Ubuntu and RHEL/Fedora,
setting `RUBY_INSTALL_METHOD=homebrew` before running `dotfiles-ruby install`
(or `update`) switches to installing Ruby via Homebrew (Linuxbrew) instead.

This is **opt-in only** — the default (`RUBY_INSTALL_METHOD` unset, or
`system`) is completely unchanged. Scope:

- Debian/Ubuntu and RHEL/Fedora: opt-in via the env var, as described here.
- Arch/SteamOS: unaffected — stays on `pacman`. Arch is rolling-release, so
  its system Ruby/libs are already current; this isn't where the pain is.
- Termux: unsupported (no Linuxbrew on Bionic libc).
- macOS: unaffected — already uses native Homebrew for everything.

See [issue #237](https://github.com/jcchikikomori/.dotfiles/issues/237) for
the original motivation. On the stable-distro default (system) path,
`dotfiles-ruby` also prints a one-line reminder that this option exists if
you ever hit a native gem build error.

## What it installs

- Homebrew's own `ruby` formula (a prebuilt bottle).
- A small, additive set of native gem build dependencies via Homebrew:
  `openssl`, `libffi`, `libyaml`, `mysql-client`, `imagemagick`. This list is
  intentionally minimal, not exhaustive — a given `Gemfile` may still need
  extra formulae (e.g. `postgresql`, `libxml2`) installed the same way
  (`brew install <formula>`) for its own native gems to build.

## Why this needs more than "just install Homebrew Ruby"

A naive setup — installing Linuxbrew alongside an existing system-toolchain
Ruby — can make native gem extensions (`bundle install`) *worse*, not
better, because the machine now has two toolchains (system gcc/ld/glibc and
Linuxbrew's own gcc/ld/glibc) on the same `PATH`. This was hit for real on
a separate Rails project and is worth understanding before debugging a
mysterious native-extension failure:

- **Symptom class 1**: `msgpack`/`rbtree`-style gems fail with
  `undefined reference to 'crypt_r@XCRYPT_2.0'`. Cause: Linuxbrew's `ld`
  (vanilla upstream binutils, no distro patches) doesn't have the distro's
  multiarch library search dirs baked in, so it can't resolve a
  transitively-needed system library. `-L`/`LIBRARY_PATH` does **not** fix
  this — those only affect libraries named directly on the link command,
  not ones pulled in indirectly through another `.so`'s own dependencies.
- **Symptom class 2**: fixing symptom 1 by forcing the system `ld` can then
  break gems like `rmagick` against Linuxbrew's own `ImageMagick`, with
  errors like `undefined reference to 'fmod@GLIBC_2.38'` — because
  Linuxbrew ships its own newer glibc for formulas that need it. A single
  process can only ever load **one** glibc, chosen by whichever loader the
  entry executable was linked against. No amount of `-rpath`/
  `-rpath-link`/`LD_LIBRARY_PATH` trickery fixes this; it's a process
  lifetime constraint, not a search-path one.

The actual fix is keeping **one consistent toolchain end-to-end**. Using
Homebrew's own prebuilt `ruby` bottle gets this for free — it's already
self-consistently linked against Linuxbrew's own glibc/toolchain, so the
native extensions you build against it (and the Homebrew-installed native
libs above) stay consistent too.

If a project pins a specific Ruby version that isn't available as a
Homebrew bottle and needs to be source-compiled via `rbenv`/`ruby-build`,
that build must force `CC`/`CXX` to Homebrew's own `gcc`/`g++` (and put
Homebrew's `bin` first on `PATH`) for that one build only — see
`install_ruby_pinned_homebrew()` in `dotfiles-ruby` for the reference
implementation of this guard.

## Diagnosing a broken toolchain

`dotfiles-ruby doctor` is a report-only diagnostic (makes no changes): it
prints the active ruby/gem and their resolved paths, `Gem.dir` and whether
it's writable, every `ruby` binary found on `PATH` tagged by which install
method produced it (`system`/`rbenv`/`homebrew`/`other`), and warns if more
than one is present at once (the mixed-toolchain condition described
below) or if `RUBY_INSTALL_METHOD=homebrew` is set but the active `ruby`
isn't actually a Homebrew one (usually means `brew shellenv` isn't loaded
in the current shell).

## Troubleshooting

- **A gem — or Ruby itself, if you're source-compiling an old pinned
  version via `install_ruby_pinned_homebrew` — suddenly fails with a C
  error like `passing argument N ... from incompatible pointer type` or
  `conflicting types for '...'`.** Homebrew's `gcc` is often much newer
  than the distro's, and newer GCC versions turn some old warnings
  (`-Wincompatible-pointer-types`, `-Wimplicit-function-declaration`) into
  hard errors. This isn't something dotfiles can fix generically — it
  means the code has a real (if previously-ignored) bug. Confirmed live:
  building Ruby 2.5.3 from source with Homebrew's GCC 16 fails during
  `make` with
  `enc/jis/props.kwd:146:1: error: conflicting types for 'onig_jis_property'`
  — Ruby 2.5.3's Oniguruma-derived encoding source is simply too old for
  GCC 16's stricter defaults. There's no dotfiles-level fix for this; it
  means that specific old Ruby/gem version needs a newer release, a
  patch, or the distro's own (older) gcc instead of Homebrew's.
- **`bundle list`/`bundle check` keeps reporting "missing extensions"
  right after a Ruby rebuild or reinstall, even though nothing looks
  actually broken.** Run a full `bundle install` (not `bundle list`/
  `bundle check`) — it cleanly rebuilds whatever the lighter-weight
  commands left in a stale state, rather than trying to hand-fix a stale
  `gem_make.out` marker.

## Per-project pinned-version guidance

If a specific project needs to pin a Homebrew-toolchain Ruby build without
forcing that choice on the whole team's shared, git-tracked
`.ruby-version` file, keep `.ruby-version` untouched and add a
gitignored `.envrc` (via [direnv](https://direnv.net/)) in that project's
repo root:

```sh
export RBENV_VERSION=<version>-brew
```

From inside the project's repo root, `dotfiles-ruby envrc <version>` writes
this for you (creating `.envrc` or appending to an existing one without
touching other content) and runs `direnv allow` if direnv is installed.
`.envrc` is already covered by the global `~/.config/git/ignore` shipped by
the `git` stow package, so it won't get accidentally committed.

This remains a per-project, per-machine choice, not something dotfiles
applies globally on its own — `dotfiles-ruby envrc` is a convenience for
writing it, not an automatic decision about which projects need it.

## Python

`dotfiles-python` has the equivalent idea already: `PYTHON_INSTALL_METHOD=homebrew`
installs Python via Homebrew instead of `pyenv`/`uv`/`conda`. See
`dotfiles-python`'s own `install homebrew` subcommand.
