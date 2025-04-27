#!/usr/bin/env bash

echo "Manual setup"

echo "bash fzf: https://github.com/junegunn/fzf.git to ~/.fzf"
git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

echo "bash fasd: https://github.com/clvv/fasd.git to ~/.fasd"
git clone -q --depth 1 https://github.com/clvv/fasd.git ~/.fasd

echo "zsh ohm-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "tmux tpm: https://github.com/tmux-plugins/tpm to ~/.tmux/plugins/tpm"
git clone -q --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "vim plug: https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Setup fzf"
~/.fzf/install

echo "Setting up fasd"
cd ~/.fasd
PREFIX=$HOME make install
$HOME/bin/fasd --init auto

cd $HOME

echo "Installing vim plugins"
vim +'PlugInstall --sync' +qa
