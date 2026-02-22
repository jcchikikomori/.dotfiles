# =============================================================================
# Steam Dark Theme for Tmux Powerline
# =============================================================================
# Steam color scheme: #1B2838 (primary), #0E1419 (darker), #00BFFF (cyan)
# Left: hostname
# Right: battery | CPU | date
# =============================================================================

# Segments shown on left side of status bar
export TMUX_POWERLINE_SEG_LEFT_ONLY=(
    "hostname"
)

# Segments shown on right side of status bar
export TMUX_POWERLINE_SEG_RIGHT_ONLY=(
    "battery"
    "cpu"
    "date"
)

# All segments (used for both sides)
export TMUX_POWERLINE_SEG_MAIN=(
    "hostname"
    "battery"
    "cpu"
    "date"
)

# =============================================================================
# Color Configuration
# =============================================================================

# Status bar background: Steam dark
export TMUX_POWERLINE_COLOR_BG="#1B2838"

# Status bar foreground (text): White
export TMUX_POWERLINE_COLOR_FG="#FFFFFF"

# Powerline segment colors
export TMUX_POWERLINE_COLOR_PRIMARY_BG="#1B2838"
export TMUX_POWERLINE_COLOR_PRIMARY_FG="#FFFFFF"

export TMUX_POWERLINE_COLOR_SECONDARY_BG="#0E1419"
export TMUX_POWERLINE_COLOR_SECONDARY_FG="#00BFFF"

# Highlight/accent color
export TMUX_POWERLINE_COLOR_ACCENT_BG="#00BFFF"
export TMUX_POWERLINE_COLOR_ACCENT_FG="#000000"

# =============================================================================
# Character/Symbol Configuration
# =============================================================================

# Left powerline symbol
export TMUX_POWERLINE_LEFT_SYMBOL=""

# Right powerline symbol
export TMUX_POWERLINE_RIGHT_SYMBOL=""

# Separator
export TMUX_POWERLINE_SEP_LEFT=""
export TMUX_POWERLINE_SEP_RIGHT=""
