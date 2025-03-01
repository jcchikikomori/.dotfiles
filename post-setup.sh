#!/bin/bash

# Helper functions
setup_directory() {
    ORIGINAL_DIR=$(pwd)
    WORKDIR=$(mktemp -d)
    trap 'rm -rf "$WORKDIR"' EXIT
    cp -r git.sh python.sh nodejs.sh php.sh $WORKDIR
    cd "$WORKDIR"
}

check_script() {
    local script_name=$1
    if [ ! -f "./$script_name" ]; then
        echo "Error: $script_name not found in the current directory ($PWD)"
        exit 1
    fi
}

prompt_installation() {
    local name=$1
    local script=$2
    local default_choice="y"
    
    # Check if we're in unattended mode
    if [ -n "${SKIP_INSTALL_PROGLANG}" ]; then
        echo "Unattended mode: Skipping $name installation"
        return
    fi
    
    # Interactive mode
    read -p "Do you want to install $name? (y/n): " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        echo "Installing $name..."
        ./"$script"
    else
        echo "Skipped. You can install $name later."
    fi
}

# Main setup function
main() {
    setup_directory
    
    # Check for required scripts
    for SCRIPT in git.sh python.sh nodejs.sh php.sh; do
        check_script "$SCRIPT"
    done
    
    # Core installations
    echo 'Setting up git flow...'
    ./"git.sh"
    
    echo "Symlinking state dir..."
    mkdir -p "$HOME/.local/state/dotstow"
    ln -s "$HOME/.dotfiles" "$HOME/.local/state/dotstow/dotfiles"
    
    echo 'Setting up bash fzf...'
    git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || true
    ~/.fzf/install
    
    echo 'Setting up bash fasd...'
    git clone -q --depth 1 https://github.com/clvv/fasd.git ~/.fasd || true
    
    echo 'Setting up Vim Plug...'
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    
    echo 'Setting up Tmux configuration...'
    git clone https://github.com/jcchikikomori/.tmux.git ~/.tmux || true
    cd ~/.tmux && git reset --hard fd1bbb56148101f4b286ddafd98f2ac2dcd69cd8 && ..
    ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
    
    echo 'Setting up Tmux TPM...'
    git clone -q --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || true
    
    echo 'Setting up Starship prompt...'
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    
    echo 'Setting up Antigen...'
    curl -L https://git.io/antigen >"$HOME/antigen.zsh"
    
    # Optional installations with prompts
    prompt_installation "python with pyenv" "python.sh"
    prompt_installation "SDKMAN" "" "sdkman.sh"
    prompt_installation "NodeJS with NVM" "nodejs.sh"
    prompt_installation "PHP with phpenv" "php.sh"
    
    echo 'Installing VIM Plugins...'
    vim +'PlugInstall --sync' +qall >/dev/null 2>&1
    
    echo 'Setting up oh-my-zsh'
    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended
    git clone https://github.com/bobthecow/git-flow-completion ~/.ohmy-zsh/custom/plugins/git-flow-completion
    
    # Return to original directory
    cd "$ORIGINAL_DIR"
    
    # Clean up temporary directory
    rm -rf "$WORKDIR"
}

# Execute main function
main
