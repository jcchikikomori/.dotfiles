#!/bin/sh

# =============================================================================
# Battery Status Segment for Tmux Powerline
# Shows battery percentage and status (charging, discharging, full)
# =============================================================================

BATTERY_PATH="/sys/class/power_supply"

# Try BAT0 or BAT1
PERCENT=""
for bat in BAT0 BAT1; do
    if [ -f "$BATTERY_PATH/$bat/capacity" ]; then
        PERCENT=$(cat "$BATTERY_PATH/$bat/capacity" 2>/dev/null)
        STATUS=$(cat "$BATTERY_PATH/$bat/status" 2>/dev/null)
        break
    fi
done

# Fallback to AC
if [ -z "$PERCENT" ] && [ -f "$BATTERY_PATH/AC0/online" ]; then
    if [ "$(cat "$BATTERY_PATH/AC0/online" 2>/dev/null)" = "1" ]; then
        echo "AC"
        exit 0
    fi
fi

# Output result or N/A
if [ -n "$PERCENT" ]; then
    case "$STATUS" in
        Charging) echo "${PERCENT}%+" ;;
        Discharging) echo "${PERCENT}%-" ;;
        *) echo "${PERCENT}%" ;;
    esac
else
    echo "N/A"
fi
