#!/bin/bash
# Configuration
LOCK_FILE="/tmp/vim-plugin-install.lock"
WORKDIR="$HOME"
ORIGINAL_DIR=$(pwd)

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

cleanup() {
    rm -f "/tmp/vim-verbose.log"
    cd "$ORIGINAL_DIR" || true
}

# Main installation function
install_plugins() {
    log_message "Installing vim-plug..."
    mkdir -p ~/.vim/autoload
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    if [ $? -ne 0 ]; then
        log_message "Failed to download vim-plug"
        return 1
    fi
    (
        flock -n 200 || {
            log_message "Another installation is in progress"
            exit 1
        }
        log_message "Starting plugin installation..."
        vim +"set verbosefile=/tmp/vim-verbose.log" \
            "+PlugInstall --sync" \
            "+qall!"
        STATUS=$?
        case $STATUS in
            0)
                log_message "Plugins installed successfully"
                ;;
            *)
                log_message "Plugin installation failed with status $STATUS"
                ;;
        esac
        exit $STATUS
    ) 200>$LOCK_FILE
}

# Main execution
trap cleanup EXIT
install_plugins
EXIT_STATUS=$?
log_message "Final status: $EXIT_STATUS"
exit $EXIT_STATUS