# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Auto-add SSH
if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval `ssh-agent -s`
    ssh-add
fi

# SSH Agent
# References:
# https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user
# https://owensgl.github.io/biol525D/Topic_1/configure_ssh_agent
if [ -z "$(pgrep ssh-agent)" ]; then
  rm -rf '/tmp/ssh-*'
  eval "$(ssh-agent -s)" >/dev/null
else
  export SSH_AGENT_PID=$(pgrep ssh-agent)
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# Linuxbrew/Homebrew
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
    echo "Warning: Homebrew is not installed or not executable at /home/linuxbrew/.linuxbrew/bin/brew" >&2
fi

# Locally installed binaries
export PATH="${HOME}/bin:${PATH}"
export EDITOR=nano

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# phpenv
export PHPENV_ROOT="$HOME/.phpenv"
if [ -d "$PHPENV_ROOT" ]; then
  export PATH="$PHPENV_ROOT/bin:$PATH"
  eval "$(phpenv init -)"
fi

# TMUX
export DISABLE_AUTO_TITLE=1
export TMUX_DISABLE_AT_BOOT=1

# sdkman
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# DXVK
export DXVK_CONFIG_FILE=$HOME/.dxvk/dxvk.conf
export DXVK_STATE_CACHE_PATH=$HOME/.dxvk/cache
export DXVK_LOG_PATH=$HOME/.dxvk/log

# Disabling HiDPI
#export GDK_SCALE=1

# Resetting values for deprecated QT properties
export QT_SCREEN_SCALE_FACTORS=
export QT_SCALE_FACTOR=
export QT_AUTO_SCREEN_SCALE_FACTOR=

# GPG-related TTY fix
export GPG_TTY=$(tty)

# OS-related workarounds
if [ -f /etc/os-release ]; then
  source /etc/os-release
  case $ID in
  ubuntu)
    echo "Distribution: Ubuntu"
    ;;
  debian)
    echo "Distribution: Debian"
    ;;
  arch)
    if [[ $NAME == *"Arch Linux"* ]]; then
      echo "Distribution: Arch Linux Barebones"
    else
      echo "Distribution: Unknown"
    fi
    ;;
  garuda)
    echo "Distribution: Garuda Linux"
    ;;
  manjaro)
    echo "Distribution: Manjaro"
    ;;
  fedora*)
    echo "Distribution: Fedora"

    # Ensure include the installed libraries from system before compiling software
    export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH}"
    # Ensure path for GO programming language
    export GOPATH="${HOME}/go"
    ;;
  *)
    echo "Distribution: Unknown"
    ;;
  esac
elif [ -f /etc/redhat-release ]; then
  echo "Distribution: $(cat /etc/redhat-release)"
elif [ -f /etc/debian_version ]; then
  echo "Distribution: Debian-based"
else
  echo "Distribution: Unknown"
fi

# Stow Me!
alias stowme='echo "Under construction" && stow -v --no-folding --no-backups'

## Useful aliases
# alias grubup="sudo update-grub" # unmaintained
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
# alias rmpkg="sudo pacman -Rdd" # unmaintained
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias hw='hwinfo --short'                                   # Hardware Info

# Misc alias
alias please='sudo'
# alias fetch='sudo apt-get update' # unmaintained
# alias upgrademe='sudo apt-get upgrade' # unmaintained

# Start TMUX on the end after executing everything...
# To disable tmux at boot, set $TMUX_DISABLE_AT_BOOT to true
if [ -z "$TMUX" ] && [ -z $TMUX_DISABLE_AT_BOOT ]; then
  tmux attach || tmux new
fi
