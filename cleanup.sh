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
dotstow unstow bash antigen tmux tmuxp vim vscode systems dxvk
cp -rf $HOME/.zsh $HOME/.backups
cp -rf $HOME/.git $HOME/.backups
cp -rf $HOME/.ssh $HOME/.backups
dotstow unstow zsh git ssh
