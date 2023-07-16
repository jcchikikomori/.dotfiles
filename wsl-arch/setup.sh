#!/bin/sh

# Setting default locale
sudo sed -i '/^# *en_US.UTF-8 UTF-8/s/^# *//' /etc/locale.gen

# Install essentials
sudo pacman -Syyu --noconfirm --noprogressbar
sudo pacman -S --noconfirm --noprogressbar base-devel git python3 zip unzip
mkdir -p temp && cd temp/
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ../../
rm -rf temp/

# Install Chaotic-AUR
sudo pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com || true
sudo pacman-ket --init  || true
sudo pacman-key --lsign-key FBA220DFC880C036  || true
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'  || true

# New method on setting up systemctl
# Source: https://github.com/nullpo-head/wsl-distrod
curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
chmod +x install.sh
sudo ./install.sh install
rm -f install.sh

# If you want to automatically start your distro on Windows startup, enable distrod by the following command
#/opt/distrod/bin/distrod enable --start-on-windows-boot
# Otherwise
/opt/distrod/bin/distrod enable

# SSH Keys
ssh-keygen -t ed25519 -C "jccorsanes@protonmail.com" || true
ssh-keygen -t rsa -b 4096 -C "jccorsanes@protonmail.com" || true

# NVM
yay -S --noconfirm --noprogressbar chaotic-aur/nvm
# Workarounds & Misc softwares
yay -S --noconfirm --noprogressbar aur/pam_ssh_agent_auth
# Programming languages
yay -S --noconfirm --noprogressbar pyenv rbenv chaotic-aur/nvm
pyenv install 3.11.4 -v
pyenv global 3.11.4
nvm install 18 --lts
npm install -g dotstow
# Programming languages: SDKMAN
curl -s "https://get.sdkman.io" | bash

# Setting up bash fzf
git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || true; ~/.fzf/install;
# Setting up bash fasd
git clone -q --depth 1 https://github.com/clvv/fasd.git ~/.fasd || true
# Setting up Vim Plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Setting up Tmux TPM
git clone -q --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || true
# Always put this oh-my-zsh into the end
yay -S --noconfirm --noprogressbar stow tmux starship antigen
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
