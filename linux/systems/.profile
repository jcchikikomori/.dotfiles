# Distribution detection and setup
export DETECTED_DISTRO="unknown"
if [ -f /etc/os-release ]; then
    source /etc/os-release
    export DETECTED_DISTRO=$ID
    export DETECTED_DISTRO_NAME=$NAME
    case $ID in
        ubuntu|debian)
            # Debian-based systems
            export DETECTED_DISTRO="debian"
            export DEBIAN_FRONTEND=noninteractive
            ;;
        fedora|centos|rhel)
            # Red Hat-based systems
            export DETECTED_DISTRO="rhel"
            export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH}"
            ;;
        arch|garuda|manjaro|cachyos|steamos)
            # Arch-based systems
            export DETECTED_DISTRO="arch"
            export MAKEFLAGS="-j$(nproc)"
            ;;
        bazzite)
            export DETECTED_DISTRO="fedoraimmmutable"
            echo -e "\nWarning: Bazzite is not officially supported. Proceed with caution."
            ;;
        *)
            echo -e "\nWarning: Unable to detect distribution. Default settings will be used."
            ;;
    esac
    # Include $VERSION_ID if exists
    # Execute `clear` if exists
    # if [ -f /usr/bin/clear ]; then
    #     clear
    # fi
    # Suppress welcome message is the shell is being run from tmux session (if $TMUX exists).
    if [ -z "$TMUX" ]; then
        if [ -n "$VERSION_ID" ]; then
            echo -e "Detected distribution: $NAME ($VERSION_ID)"
        else
            echo -e "Detected distribution: $NAME"
        fi
        echo -e "\nWelcome, $USER!"
    fi
fi

# Core environment variables
export EDITOR=vim
export PATH="${HOME}/bin:${PATH}"

# Development environments
export PYENV_ROOT="$HOME/.pyenv"
export RBENV_ROOT="$HOME/.rbenv"
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
export SDKMAN_DIR="$HOME/.sdkman"
export GOPATH="${HOME}/go"

# XDG Base Directory Specification
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Linuxbrew/Homebrew
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    echo "Warning: Homebrew is not installed or not executable at /home/linuxbrew/.linuxbrew/bin/brew" >&2
fi

# phpenv
# export PHPENV_ROOT="$HOME/.phpenv"
# if [ -d "$PHPENV_ROOT" ]; then
#   export PATH="$PHPENV_ROOT/bin:$PATH"
#   eval "$(phpenv init -)"
# fi

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

# libvrt
export LIBVIRT_DEFAULT_URI="qemu:///system"

# Rootless Docker
# https://docs.docker.com/engine/security/rootless/
# export PATH=/home/patatasdeck/bin:$PATH
if command -v docker &> /dev/null; then
    echo "Found Docker CLI at: $(which docker)"
    # Detect if running inside WSL
    if grep -qi microsoft /proc/version; then
        echo "WSL2 was detected thru Docker Desktop integration with Docker."
        unset DOCKER_HOST
        echo "DOCKER_HOST has been UN-set for WSL2!"
    else
        export DOCKER_HOST="unix:///run/user/$UID/docker.sock"
    fi
else
    echo "Warning: Docker not found in PATH. Install or add it first."
fi

# Initialize development tools
if [ -d "$PYENV_ROOT" ]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    export PYENV_VERSION="3.11.4"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

if [ -d "$RBENV_ROOT" ]; then
    export PATH="$RBENV_ROOT/bin:$PATH"
    eval "$(rbenv init -)"
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
