# Distribution detection and setup
if [ -f /etc/os-release ]; then
    source /etc/os-release
    case $ID in
        ubuntu|debian)
            # Debian-based systems
            export DEBIAN_FRONTEND=noninteractive
            ;;
        fedora|centos|rhel)
            # Red Hat-based systems
            export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH}"
            ;;
        arch|garuda|manjaro)
            # Arch-based systems
            export MAKEFLAGS="-j$(nproc)"
            ;;
        bazzite)
            echo -e "\nWarning: Bazzite is not officially supported. Proceed with caution."
            ;;
        *)
            echo -e "\nWarning: Unable to detect distribution. Default settings will be used."
            ;;
    esac
    echo -e "Detected distribution: $NAME ($VERSION_ID)"
    echo -e "\nWelcome, $USER!"
fi

# Core environment variables
export EDITOR=nano
export PATH="${HOME}/bin:${PATH}"

# Development environments
export PYENV_ROOT="$HOME/.pyenv"
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
export SDKMAN_DIR="$HOME/.sdkman"
export GOPATH="${HOME}/go"

# XDG Base Directory Specification
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# SSH Agent setup
if [ -z "$(pgrep ssh-agent)" ]; then
    rm -rf '/tmp/ssh-*'
    eval "$(ssh-agent -s)" >/dev/null
else
    export SSH_AGENT_PID=$(pgrep ssh-agent)
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# Display setup
export GPG_TTY=$(tty)
export DISABLE_AUTO_TITLE=1
export TMUX_DISABLE_AT_BOOT=1

# DXVK configuration
export DXVK_CONFIG_FILE="$HOME/.dxvk/dxvk.conf"
export DXVK_STATE_CACHE_PATH="$HOME/.dxvk/cache"
export DXVK_LOG_PATH="$HOME/.dxvk/log"

# Reset deprecated QT properties
export QT_SCREEN_SCALE_FACTORS=
export QT_SCALE_FACTOR=
export QT_AUTO_SCREEN_SCALE_FACTOR=

# Initialize development tools
if [ -d "$PYENV_ROOT" ]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
fi

if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

# Start TMUX if not already running
if [ -z "$TMUX" ] && [ -z "$TMUX_DISABLE_AT_BOOT" ]; then
    tmux attach || tmux new
fi
