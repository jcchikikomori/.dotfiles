#!/bin/sh

# =============================================================================
# Date Segment for Tmux Powerline
# Shows date in M/DD/YYYY H:MMam/pm format
# =============================================================================

# Format: M/DD/YYYY h:MMam/pm
# Use portable format and remove leading zeros
DATE=$(date '+%m/%d/%Y %I:%M%p' | sed 's/^0//;s|/0|/|')
echo "$DATE"
