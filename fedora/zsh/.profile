# SSH Agent
# TODO: Does not apply for Ubuntu
# https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user
SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Auto-add SSH (not working yet)
# https://bbs.archlinux.org/viewtopic.php?id=35524
# Install this instead: aur/pam_ssh_agent_auth

export EDITOR=vim

export PHPENV_ROOT="$HOME/.phpenv"
if [ -d "${PHPENV_ROOT}" ]; then
  export PATH="${PHPENV_ROOT}/bin:${PATH}"
  eval "$(phpenv init -)"
fi

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# bun completions
# [ -s "/home/johnc/.oh-my-zsh/completions/_bun" ] && source "/home/johnc/.oh-my-zsh/completions/_bun"

# Docker (Disable this for WSL to work!)
# export PATH=/home/docker/bin:$PATH
# export DOCKER_HOST=unix:///var/run/docker.sock

# Start TMUX
# To disable tmux at boot, set $TMUX_DISABLE_AT_BOOT to true
#export TMUX_DISABLE_AT_BOOT=1
if [ -z "$TMUX" ] && [ -z $TMUX_DISABLE_AT_BOOT ]; then
  tmux attach || tmux new
fi

# TMUX
export DISABLE_AUTO_TITLE=1

# sdkman (MUST BE AFTER archlinux-java)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

## podman
#if [[ -z "$XDG_RUNTIME_DIR" ]]; then
#  export XDG_RUNTIME_DIR=/run/user/$UID
#  if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
#    export XDG_RUNTIME_DIR=/tmp/$USER-runtime
#    if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
#      mkdir -m 0700 "$XDG_RUNTIME_DIR"
#    fi
#  fi
#fi

## Check if podman service is running (rootless), and start if not.
#if ! pgrep -f -x 'podman system service -t 0' > /dev/null;then
#  podman system service -t 0 > /dev/null 2>&1 &
#fi

## Define DOCKER_HOST to podman socket, so docker-compose can work with it
## I've installed docker-compose using: pip3 install docker-compose from my user (non-root)
#DOCKER_HOST=`echo "unix://${XDG_RUNTIME_DIR}/podman/podman.sock"`
#export DOCKER_HOST

# Flatpak-related workarounds
#export PATH=/var/lib/flatpak/exports/bin:$PATH
alias code="flatpak run com.visualstudio.code"

# Fedora-related workarounds
# Ensure include the installed libraries from system before compiling software
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH}"
# Ensure path for GO programming language
export GOPATH="${HOME}/go"

# GWSL
# This directory is non-WSL
#export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0 #GWSL
#export PULSE_SERVER=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}') #GWSL
#export LIBGL_ALWAYS_INDIRECT=0 #GWSL
#export GDK_SCALE=1 #GWSL
#export QT_SCALE_FACTOR=1 #GWSL
