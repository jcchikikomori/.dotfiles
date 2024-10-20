#!/bin/sh

echo 'Backing up...'
rm -rf $HOME/.backups
mkdir -p $HOME/.backups
# cp -rf $HOME/.ssh $HOME/.backups
cp -rf $HOME/.zsh $HOME/.backups
cp -f $HOME/.zshrc $HOME/.backups
cp -f $HOME/.zshrc.pre-oh-my-zsh $HOME/.backups
cp -rf $HOME/.git $HOME/.backups

echo 'Unstowing...'
dotstow unstow zsh git antigen tmux tmuxp vim vscode systems dxvk

echo 'Cleaning up tmux...'
rm -f $HOME/.tmux.conf.local

echo 'Cleaning up VSCode...'
rm -rf $HOME/.vscode
rm -rf $HOME/.vscode-server

echo 'Cleaning up other files...'
rm -f $HOME/.vimrc
rm -f $HOME/.gitconfig

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
rm -f $HOME/.gnupg/gpg.conf
rm -f $HOME/.gnupg/gpg-agent.conf
rm -f $HOME/.zsh
rm -f $HOME/.zshrc
rm -f $HOME/.zshrc.pre-oh-my-zsh
rm -f $HOME/.git

# Avoid removing ssh
# rm -f $HOME/.ssh-backup
# cp -rf $HOME/.ssh $HOME/.ssh-backup
echo 'y' || cp -rf $HOME/.ssh $HOME/.ssh-backup
# rm -f $HOME/.ssh/config
