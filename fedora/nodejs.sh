#/bin/sh

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | zsh
# exec $SHELL
nvm install 18 --lts
nvm alias default 18
npm install -g dotstow
