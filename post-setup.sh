#!/bin/sh

setup_directory() {
    ORIGINAL_DIR=$(pwd)
    WORKDIR=$(mktemp -d)
    trap 'rm -rf "$WORKDIR"' EXIT
    cp -r install-dotstow.sh python.sh nodejs.sh php.sh java.sh ruby.sh vim.sh "$WORKDIR"
    cd "$WORKDIR"
}

check_script() {
    local script_name=$1
    if [ ! -f "./$script_name" ]; then
        echo "Error: $script_name not found in the current directory ($PWD)" >&2
        exit 1
    fi
}

prompt_installation() {
    local name=$1
    local script=$2
    local default_choice="y"
    
    if [ -n "${SKIP_INSTALL_PROGLANG}" ]; then
        echo "Unattended mode: Skipping $name installation"
        return
    fi
    
    echo "Do you want to install $name? (y/n): " >&2
    read choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        echo "Installing $name..."
        ./"$script"
    else
        echo "Skipped. You can install $name later."
    fi
}

main() {
    setup_directory
    for SCRIPT in install-dotstow.sh python.sh nodejs.sh php.sh java.sh ruby.sh vim.sh; do
        check_script "$SCRIPT"
    done

    echo 'Installing dotstow...'
    ./install-dotstow.sh
    
    echo 'Setting up bash fzf...'
    git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || true
    ~/.fzf/install
    
    echo 'Setting up bash fasd...'
    git clone -q --depth 1 https://github.com/clvv/fasd.git ~/.fasd || true
    
    echo 'Setting up Tmux configuration...'
    git clone https://github.com/jcchikikomori/.tmux.git ~/.tmux || true
    cd ~/.tmux && git reset --hard fd1bbb56148101f4b286ddafd98f2ac2dcd69cd8
    cd "$ORIGINAL_DIR"
    ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
    
    echo 'Setting up Tmux TPM...'
    git clone -q --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || true
    
    echo 'Setting up Starship prompt...'
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    
    echo 'Setting up Antigen...'
    curl -L https://git.io/antigen >"$HOME/antigen.zsh"
    
    prompt_installation "python with pyenv" "python.sh"
    prompt_installation "Ruby with rbenv" "ruby.sh"
    prompt_installation "SDKMAN" "" "java.sh"
    prompt_installation "NodeJS with NVM" "nodejs.sh"
    prompt_installation "PHP with phpenv" "php.sh"
    prompt_installation "Vim with plugins" "vim.sh"
    
    echo 'Setting up oh-my-zsh...'
    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended
    echo 'Installing zsh plugins...'
    local ZSH_CUSTOM_DIR=$HOME/.oh-my-zsh/custom
    local ZSH_CUSTOM_PLUGINS_DIR=$ZSH_CUSTOM_DIR/plugins
    git clone https://github.com/bobthecow/git-flow-completion.git $ZSH_CUSTOM_PLUGINS_DIR/git-flow-completion
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM_PLUGINS_DIR/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM_PLUGINS_DIR/zsh-syntax-highlighting
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM_PLUGINS_DIR/fast-syntax-highlighting
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM_PLUGINS_DIR/zsh-autocomplete
    git clone https://github.com/larkery/zsh-histdb.git $ZSH_CUSTOM_PLUGINS_DIR/zsh-histdb
    
    cd "$ORIGINAL_DIR"
    rm -rf "$WORKDIR"
}


echo 'Setting up git flow...'
check_script "./git.sh"
./"git.sh"
echo "Symlinking state dir..."
mkdir -p "$HOME/.local/state/dotstow"
ln -s "$HOME/.dotfiles" "$HOME/.local/state/dotstow/dotfiles"

echo 'Few more steps before executing...'
cp -f linux/vim/.vimrc ~/.vimrc
cp -f linux/vim/.virc ~/.virc

echo 'Executing post-setup...'
main
