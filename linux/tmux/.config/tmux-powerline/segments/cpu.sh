#!/bin/sh

# =============================================================================
# CPU Usage Segment for Tmux Powerline
# Shows overall CPU percentage
# =============================================================================

# Get CPU usage with fallback
if command -v top >/dev/null 2>&1; then
    CPU_USAGE=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null)
    if [ -n "$CPU_USAGE" ]; then
        echo "${CPU_USAGE}%"
    else
        echo "N/A"
    fi
else
    echo "N/A"
fi
