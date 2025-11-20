# Termux Setup

Termux is an Android terminal emulator and Linux environment app that works without rooting your device.

## Prerequisites

1. Install [Termux from F-Droid](https://f-droid.org/en/packages/com.termux/) (recommended)
   - **Do not use Google Play Store version** (outdated and incompatible)
2. Ensure you have stable internet connection
3. Grant storage permissions: `termux-setup-storage`

## Before Running Setup

### 1. Update Package Mirrors (Critical!)

Termux mirrors can be unstable. Change to a mirror close to your location:

```bash
termux-change-repo
```

Select a mirror from the list (use arrow keys and space to select).

### 2. Update System

```bash
pkg update && pkg upgrade
```

If you encounter errors, run `termux-change-repo` again and try a different mirror.

### 3. Install Git

```bash
pkg install git
```

## Installation

Clone this repository:

```bash
git clone https://github.com/jcchikikomori/.dotfiles.git $HOME/.dotfiles
cd $HOME/.dotfiles
```

Run the setup script:

```bash
./start.sh
```

The script will:
- Detect Termux environment automatically (via `$PREFIX` variable)
- Install essential packages via `pkg` (stow, vim, zsh, git, etc.)
- Run post-setup configurations
- **Only prompt for Python (pyenv)** installation

After setup completes, run:

```bash
sh termux/stowme.sh
```

## Termux-Specific Notes

### Supported Programming Languages

**✅ Officially Supported:**
- **Python** via pyenv (ARM-compatible, recommended)

**⚠️ Not Officially Supported** (ARM/Android compatibility issues):
- Ruby (rbenv)
- PHP (phpenv)
- Java (SDKMAN)
- Node.js (nvm)

You can attempt to install these manually, but they may not work reliably on ARM/Android userspace.

### Limitations

- **No root/sudo access** - All operations run as regular user
- **No systemd** - Cannot use systemctl or system services
- **Different paths** - Uses `$PREFIX` instead of `/usr`, `/bin`, `/etc`
- **Android kernel restrictions** - Some Linux syscalls are unavailable
- **Bionic libc** - Not glibc, some binaries won't work

### Package Installation

Use `pkg` instead of apt/apt-get:

```bash
pkg search <package>
pkg install <package>
pkg list-installed
```

### Terminal Issues

If you encounter terminal rendering problems:

```bash
export TERM=xterm-256color
```

(This is automatically set in `termux/setup.sh`)

### Storage Access

To access Android filesystem:

```bash
termux-setup-storage
```

This creates `~/storage` symlinks to:
- `~/storage/shared` - Internal storage
- `~/storage/downloads` - Downloads folder
- `~/storage/dcim` - Camera folder

## Troubleshooting

### Mirror Issues

If `pkg update` fails:
1. Run `termux-change-repo` again
2. Try a different mirror
3. Check your internet connection
4. Some mirrors may be temporarily down

### locale-gen Errors

Termux handles locales differently than standard Linux. The setup script handles this, but you may see warnings - these are usually harmless.

### Build Failures

Some packages require additional build tools:

```bash
pkg install binutils clang make cmake
```

## Additional Resources

- [Termux Wiki](https://wiki.termux.com/)
- [Termux GitHub](https://github.com/termux/termux-app)
- [Termux Packages](https://github.com/termux/termux-packages)
