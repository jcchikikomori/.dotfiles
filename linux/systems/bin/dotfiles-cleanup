#!/bin/sh

echo 'Backing up...'
rm -rf $HOME/.backups
mkdir -p $HOME/.backups

if [ -d "$HOME/.ssh" ]; then
  cp -rf $HOME/.ssh $HOME/.backups
fi
if [ -d "$HOME/.zsh" ]; then
  cp -rf $HOME/.zsh $HOME/.backups
fi
if [ -f "$HOME/.zshrc" ]; then
  cp -f $HOME/.zshrc $HOME/.backups
fi
if [ -f "$HOME/.zprofile" ]; then
  cp -f $HOME/.zprofile $HOME/.backups
fi
if [ -f "$HOME/.profile" ]; then
  cp -f $HOME/.profile $HOME/.backups
fi
if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
  cp -f $HOME/.zshrc.pre-oh-my-zsh $HOME/.backups
fi
if [ -d "$HOME/.git" ]; then
  cp -rf $HOME/.git $HOME/.backups
fi

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
rm -f $HOME/.zprofile
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
