#!/bin/sh

# =============================================================================
# Hostname Segment for Tmux Powerline
# Shows the system hostname
# =============================================================================

if command -v hostname >/dev/null 2>&1; then
    hostname
else
    echo "localhost"
fi
