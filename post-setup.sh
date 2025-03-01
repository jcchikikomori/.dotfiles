#!/bin/bash

# Store original directory
ORIGINAL_DIR=$(pwd)

# Create temporary working directory
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# Display current directory
echo "Current directory: $PWD"
# ls -lah .

# Check for required scripts
for SCRIPT in git.sh python.sh nodejs.sh php.sh; do
    if [ ! -f "./$SCRIPT" ]; then
        echo "Error: $SCRIPT not found in the current directory ($PWD)"
        exit 1
    fi
done

echo 'Setting up git flow...'
./git.sh

echo "Symlinking state dir..."
mkdir -p $HOME/.local/state/dotstow
ln -s $HOME/.dotfiles $HOME/.local/state/dotstow/dotfiles

echo 'Setting up bash fzf...'
git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || true
~/.fzf/install

echo 'Setting up bash fasd...'
git clone -q --depth 1 https://github.com/clvv/fasd.git ~/.fasd || true

echo 'Setting up Vim Plug...'
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# This code has directory changes!
echo 'Setting up Tmux configuration...'
git clone https://github.com/jcchikikomori/.tmux.git ~/.tmux || true
cd ~/.tmux && git reset --hard fd1bbb56148101f4b286ddafd98f2ac2dcd69cd8 && ..
# Return to original directory
cd "$ORIGINAL_DIR"
# Final changes for tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf

echo 'Setting up Tmux TPM...'
git clone -q --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || true

echo 'Setting up Starship prompt...'
curl -sS https://starship.rs/install.sh | sh -s -- -y

echo 'Setting up Antigen...'
curl -L https://git.io/antigen >$HOME/antigen.zsh

# Interactive installations
read -p "Do you want to install python with pyenv? (y/n): " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo 'Installing pyenv...'
    ./python.sh
else
    echo 'Skipped. You can install python manually on pyenv website!'
fi

read -p "Do you want to install SDKMAN? (y/n): " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo 'Installing SDKMAN...'
    curl -s "https://get.sdkman.io" | bash
else
    echo 'Skipped. You can install SDKMAN manually on their website!'
fi

read -p "Do you want to install NodeJS with NVM? (y/n): " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo 'Installing NVM...'
    ./nodejs.sh
else
    echo 'Skipped. You can execute nodejs.sh later if you wanted to.'
fi

read -p "Do you want to install PHP with phpenv? (y/n): " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo 'Installing phpenv...'
    ./php.sh
else
    echo 'Skipped. You can execute php.sh later if you wanted to.'
fi

echo 'Installing VIM Plugins...'
vim +'PlugInstall --sync' +qall >/dev/null 2>&1

echo 'Setting up oh-my-zsh'
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended
git clone https://github.com/bobthecow/git-flow-completion ~/.oh-my-zsh/custom/plugins/git-flow-completion

# Return to original directory
cd "$ORIGINAL_DIR"

# Clean up temporary directory
rm -rf "$WORKDIR"
