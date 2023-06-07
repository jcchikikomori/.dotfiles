#/bin/sh

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | zsh
exec $SHELL
nvm install 12 --lts
nvm alias default 12
npm install -g dotstow
