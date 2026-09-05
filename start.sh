#!/bin/sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTFILES_BIN_DEFAULT="$SCRIPT_DIR/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin"
DOTFILES_BIN_RESOLVED="${DOTFILES_BIN:-$DOTFILES_BIN_DEFAULT}"

if [ ! -r "$DOTFILES_BIN_RESOLVED/dotfiles-lib-output" ]; then
  echo "[dotfiles:start] Error: dotfiles-lib-output not found"
  exit 1
fi

# shellcheck source=/dev/null
. "$DOTFILES_BIN_RESOLVED/dotfiles-lib-output"

START_VERBOSE=0
for arg in "$@"; do
  case "$arg" in
    --verbose|-v)
      START_VERBOSE=1
      ;;
  esac
done

DF_PREFIX="start"
if [ "$START_VERBOSE" -eq 1 ]; then
  df_output_init --verbose
  export DOTFILES_VERBOSE=1
else
  df_output_init
fi

run_step() {
  label="$1"
  shift
  df_step "$label"
  if "$@"; then
    df_step_end 0
    return 0
  fi
  code=$?
  df_step_end "$code"
  return "$code"
}

prelim() {
  df_info "Copying/generating files needed to your home directory..."

  DOTFILES_PATH=$(pwd)
  echo "$DOTFILES_PATH" >> .currentdir

  DOTFILES_USERNAME=$(whoami)
  echo "$DOTFILES_USERNAME" >> .currentuser

  df_info "Preliminary setup done! Proceeding with the rest of the setup..."
}

generate_bashrc() {
  df_info "Generating .bashrc from system..."
  if [ -f /etc/skel/.bashrc ]; then
    cp -f /etc/skel/.bashrc "$HOME/.bashrc"
    df_info "Generated .bashrc from system."
  else
    df_info "System .bashrc not found. Skipping generation."
  fi
}

detect_distro() {
  DETECTED_DISTRO="unknown"
  mkdir -p "$HOME/.config"
  touch "$HOME/.dotfiles-distro"

  if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX" ] && echo "$PREFIX" | grep -q "com.termux"; then
    df_info "You are using Termux (Android)"
    DETECTED_DISTRO="termux"
    echo "$DETECTED_DISTRO" >> "$HOME/.dotfiles-distro"
    return 0
  fi

  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    df_info "You are using macOS"
    DETECTED_DISTRO="darwin"
    echo "$DETECTED_DISTRO" >> "$HOME/.dotfiles-distro"
    return 0
  fi

  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu)
        df_info "You are using Ubuntu"
        DETECTED_DISTRO="ubuntu"
        ;;
      debian)
        df_info "You are using Debian"
        DETECTED_DISTRO="debian"
        DEBIAN_FRONTEND=noninteractive
        export DEBIAN_FRONTEND
        ;;
      arch|garuda|manjaro|cachyos)
        case "$NAME" in
          *"Arch Linux"*)
            df_info "You are using Arch Linux Barebones"
            DETECTED_DISTRO="archbtw"
            ;;
          *)
            df_info "You are using Arch Linux"
            DETECTED_DISTRO="arch"
            ;;
        esac
        MAKEFLAGS="-j$(nproc)"
        export MAKEFLAGS
        ;;
      steamos)
        df_info "You are using SteamOS"
        DETECTED_DISTRO="steamos"
        ;;
      fedora|centos|rhel)
        df_info "You are using Fedora/CentOS/RHEL"
        PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"
        GOPATH="${HOME}/go"
        DETECTED_DISTRO="rhel"
        export PKG_CONFIG_PATH GOPATH
        ;;
      bazzite)
        df_fail "You are using Bazzite Linux. Please install using distrobox. Exiting..."
        ;;
      *)
        df_fail "You are using Unknown OS. Exiting..."
        ;;
    esac
    echo "$DETECTED_DISTRO" >> "$HOME/.dotfiles-distro"
    return 0
  fi

  if [ -f /etc/redhat-release ]; then
    df_info "You are using $(cat /etc/redhat-release)"
    DETECTED_DISTRO="rhel"
    return 0
  fi

  if [ -f /etc/debian_version ]; then
    df_info "You are using Debian-based distro"
    DETECTED_DISTRO="debian"
    return 0
  fi

  df_fail "Unable to identify the OS. Exiting..."
}

run_distro_setup() {
  case "$DETECTED_DISTRO" in
    termux)
      run_step "Executing Termux-related workarounds" sh termux/setup.sh || return $?
      run_step "Running post-setup" sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup || return $?
      run_step "Running bash setup" sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-bash install || return $?
      ;;
    darwin)
      run_step "Executing macOS-related workarounds" sh darwin/setup.sh || return $?
      run_step "Running post-setup" sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup || return $?
      ;;
    debian)
      run_step "Executing Debian-related workarounds" sh debian/setup.sh || return $?
      run_step "Running post-setup" sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup || return $?
      ;;
    ubuntu)
      run_step "Executing Ubuntu-related workarounds" sh ubuntu/setup.sh || return $?
      run_step "Running post-setup" sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup || return $?
      ;;
    archbtw)
      df_info "Executing Arch-related (btw) workarounds..."
      if [ -n "${CI:-}" ]; then
        run_step "Executing init.sh (CI/CD mode)" sh arch/init.sh || return $?
      elif [ "$(id -u)" -ne 0 ]; then
        run_step "Executing init.sh as root" sudo sh arch/init.sh || return $?
      fi
      run_step "Executing Arch setup" sh arch/setup.sh || return $?
      run_step "Running post-setup" sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup || return $?
      ;;
    arch)
      run_step "Executing Arch-related workarounds" sh arch/setup.sh || return $?
      run_step "Running post-setup" sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup || return $?
      ;;
    steamos)
      run_step "Executing SteamOS-related workarounds" sh steamos/setup.sh || return $?
      run_step "Running post-setup" sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup || return $?
      run_step "Running bash setup" sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-bash install || return $?
      ;;
    rhel)
      run_step "Executing RHEL-related workarounds" sh rhel/setup.sh || return $?
      run_step "Installing VSCode" sh rhel/vscode.sh || return $?
      run_step "Running post-setup" sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-post-setup || return $?
      ;;
    *)
      df_fail "Unable to identify the distro to begin! Exiting..."
      ;;
  esac
}

df_info "Welcome! Beginning setup..."
run_step "Generate .bashrc" generate_bashrc || exit $?
run_step "Preliminary setup" prelim || exit $?
run_step "Detect operating system" detect_distro || exit $?

if [ -n "${DETECTED_DISTRO:-}" ]; then
  df_info "Detected distro: $DETECTED_DISTRO"
  run_distro_setup || exit $?
else
  df_fail "Unable to identify the distro. Exiting..."
fi
