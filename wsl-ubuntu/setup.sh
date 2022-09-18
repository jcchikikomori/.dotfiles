#/bin/sh

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt-get install -y git zsh

git clone https://github.com/DamionGans/ubuntu-wsl2-systemd-script.git /tmp/setup-systemd
bash /tmp/setup-systemd/ubuntu-wsl2-systemd-script.sh

curl -sS https://starship.rs/install.sh | sh
curl -L git.io/antigen > $HOME/antigen.zsh

# always put this oh-my-zsh into the end
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
