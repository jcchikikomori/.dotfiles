# ibus-daemon -d -x
export EDITOR=vim
export BROWSER=microsoft-edge-stable
#export TERM=alacritty
#export MAIL=evolution
#export QT_QPA_PLATFORMTHEME="qt5ct"
#export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# NVM
# source /usr/share/nvm/init-nvm.sh

# Docker
export PATH=/home/docker/bin:$PATH
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Start TMUX
if [ -z "$TMUX" ]; then
  tmux attach || tmux new
fi
