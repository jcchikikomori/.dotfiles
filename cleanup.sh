#!/bin/sh

mkdir -p $HOME/.backups

echo 'Cleaning up tmux...'
rm -rf $HOME/.tmux
rm -f $HOME/.tmux.conf
rm -f $HOME/.tmux.conf.local

echo 'Cleaning up other files...'
rm -f $HOME/.vimrc $HOME/.backups
rm -f $HOME/.gitconfig $HOME/.backups

echo 'Unstowing...'
# dotstow unstow bash antigen tmux tmuxp vim vscode systems dxvk
rm -f $HOME/.alacritty.yml
rm -f $HOME/.antigenrc
rm -f $HOME/bash_completion.d
rm -f $HOME/bin
rm -f $HOME/default.yml
rm -f $HOME/.dxvk
rm -f $HOME/.hushlogin
rm -f $HOME/.profile
rm -f $HOME/.tmuxp
rm -f $HOME/.vimrc
rm -f $HOME/.vscode
# dotstow unstow zsh git ssh
cp -rf $HOME/.zsh $HOME/.backups
cp -f $HOME/.zshrc $HOME/.backups
cp -f $HOME/.zshrc.pre-oh-my-zsh $HOME/.backups
cp -rf $HOME/.git $HOME/.backups
cp -rf $HOME/.ssh $HOME/.backups
rm -f $HOME/.zsh
rm -f $HOME/.zshrc
rm -f $HOME/.zshrc.pre-oh-my-zsh
rm -f $HOME/.git
rm -f $HOME/.ssh
