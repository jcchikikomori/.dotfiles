# SSH Agent
# References:
# https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user
# https://owensgl.github.io/biol525D/Topic_1/configure_ssh_agent
if [ -z "$(pgrep ssh-agent)" ]; then
    rm -rf '/tmp/ssh-*'
    eval "$(ssh-agent -s)" > /dev/null
else
    export SSH_AGENT_PID=$(pgrep ssh-agent)
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# Locally installed binaries
export PATH="${HOME}/bin:${PATH}"
export EDITOR=nano

# phpenv
export PHPENV_ROOT="$HOME/.phpenv"
if [ -d "${PHPENV_ROOT}" ]; then
  export PATH="${PHPENV_ROOT}/bin:${PATH}"
  eval "$(phpenv init -)"
fi

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# TMUX
export DISABLE_AUTO_TITLE=1

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

# WSL2-related
if [ -z "$WSL_DISTRO_NAME" ]; then
  # Execute non-WSL related workarounds
  # Flatpak-related workarounds
  # export PATH=/var/lib/flatpak/exports/bin:$PATH
  # alias code="flatpak run com.visualstudio.code"
  # alias chromium-browser="flatpak run org.chromium.Chromium"
  # alias steam="flatpak run com.valvesoftware.Steam"
  # alias PPSSPP="flatpak run org.ppsspp.PPSSPP"
  # alias vlc="flatpak run org.videolan.VLC"
else
  # Execute WSL-related workarounds
  export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0 #GWSL
  export PULSE_SERVER=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}') #GWSL
  export LIBGL_ALWAYS_INDIRECT=0 #GWSL
  export GDK_SCALE=0.5 #GWSL
  export QT_SCALE_FACTOR=1 #GWSL
  export GDK_DPI_SCALE=1
fi

# Check if the .wslprofile file exists, then source it
# if [[ -f ~/.wslprofile ]]; then
#     source ~/.wslprofile
# fi

# Check if the .dotprofile file exists, then source it
if [[ -f ~/.dotprofile ]]; then
    source ~/.dotprofile
fi

# Start TMUX on the end after executing everything...
# To disable tmux at boot, set $TMUX_DISABLE_AT_BOOT to true
if [ -z "$TMUX" ] && [ -z $TMUX_DISABLE_AT_BOOT ]; then
  tmux attach || tmux new
fi
