# SSH Agent
# References:
# https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user
# https://owensgl.github.io/biol525D/Topic_1/configure_ssh_agent
# Note: Unstable on Arch. Use aur/pam_ssh_agent_auth
if [ -z "$(pgrep ssh-agent)" ]; then
    rm -rf '/tmp/ssh-*'
    eval "$(ssh-agent -s)" > /dev/null
else
    export SSH_AGENT_PID=$(pgrep ssh-agent)
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# ibus-daemon -d -x
export EDITOR=vim
#export BROWSER=microsoft-edge-stable
export BROWSER=wslview
#export TERM=alacritty
#export MAIL=evolution
#export QT_QPA_PLATFORMTHEME="qt5ct"
#export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

export PHPENV_ROOT="$HOME/myphpenv"
if [ -d "${PHPENV_ROOT}" ]; then
  export PATH="${PHPENV_ROOT}/bin:${PATH}"
  eval "$(phpenv init -)"
fi

# NVM
source /usr/share/nvm/init-nvm.sh

# Docker (Disable this for WSL to work!)
# export PATH=/home/docker/bin:$PATH
# export DOCKER_HOST=unix:///var/run/docker.sock

# Start TMUX
# To disable tmux at boot, set $TMUX_DISABLE_AT_BOOT to true
# export TMUX_DISABLE_AT_BOOT=true
export DISABLE_AUTO_TITLE=true
if [ -z "$TMUX" ] && [ -z $TMUX_DISABLE_AT_BOOT ]; then
  tmux attach || tmux new
fi

# FOR: chaotic-aur/android-sdk
# FOR: chaotic-aur/sdkmanager
export ANDROID_SDK_ROOT=/opt/android-sdk
export ANDROID_AVD_HOME=$HOME/.android/avd

# archlinux-java
export JAVA_HOME=/usr/lib/jvm/default

# sdkman (MUST BE AFTER archlinux-java)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# GPG Workarounds (for signing commits)
export GPG_TTY=$(tty)

# GWSL
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0 #GWSL
export PULSE_SERVER=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}') #GWSL
export LIBGL_ALWAYS_INDIRECT=0 #GWSL
export GDK_SCALE=0.5 #GWSL
export QT_SCALE_FACTOR=1 #GWSL
export GDK_DPI_SCALE=1

