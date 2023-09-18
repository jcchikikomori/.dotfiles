#!/bin/sh

echo "Symlinking state dir..."
mkdir -p $HOME/.local/state/dotstow
ln -s $HOME/.dotfiles $HOME/.local/state/dotstow/dotfiles

echo 'Setting up bash fzf...'
git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || true; ~/.fzf/install;

echo 'Setting up bash fasd...'
git clone -q --depth 1 https://github.com/clvv/fasd.git ~/.fasd || true

echo 'Setting up Vim Plug...'
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo 'Setting up Tmux TPM...'
git clone -q --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || true

echo 'Setting up Starship prompt...'
curl -sS https://starship.rs/install.sh | sh -s -- -y

echo 'Setting up Antigen...'
curl -L https://git.io/antigen > $HOME/antigen.zsh

echo 'Installing pyenv...'
curl https://pyenv.run | bash

read -p "Do you want to install NodeJS with NVM? (y/n): " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo 'Installing NVM...'
    ./nodejs.sh
else
    echo 'Skipped. You can execute nodejs.sh later if you wanted to.'
fi

echo 'Installing VIM Plugins...'
vim +'PlugInstall --sync' +qall > /dev/null 2>&1

echo 'Setting up oh-my-zsh'
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended
