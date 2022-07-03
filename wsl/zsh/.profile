# SSH Agent
# https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user
SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Auto-add SSH (not working yet)
# https://bbs.archlinux.org/viewtopic.php?id=35524
# Install this instead: aur/pam_ssh_agent_auth

# ibus-daemon -d -x
export EDITOR=vim
#export BROWSER=microsoft-edge-stable
export BROWSER=wslview
#export TERM=alacritty
#export MAIL=evolution
#export QT_QPA_PLATFORMTHEME="qt5ct"
#export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# NVM
# source /usr/share/nvm/init-nvm.sh

# Docker (Disable this for WSL to work!)
# export PATH=/home/docker/bin:$PATH
# export DOCKER_HOST=unix:///var/run/docker.sock

# Start TMUX
if [ -z "$TMUX" ]; then
  tmux attach || tmux new
fi

# TMUX
export DISABLE_AUTO_TITLE='true'

# FOR: chaotic-aur/android-sdk
# FOR: chaotic-aur/sdkmanager
export ANDROID_SDK_ROOT=/opt/android-sdk
export ANDROID_AVD_HOME=$HOME/.android/avd

# GWSL
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0 #GWSL
export PULSE_SERVER=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}') #GWSL
export LIBGL_ALWAYS_INDIRECT=1 #GWSL
export GDK_SCALE=1 #GWSL
export QT_SCALE_FACTOR=1 #GWSL
