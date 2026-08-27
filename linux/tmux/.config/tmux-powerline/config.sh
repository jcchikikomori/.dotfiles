# shellcheck shell=bash
# tmux-powerline config for the SteamOS theme.
# Recreates the previous hand-rolled status-left/status-right (session name,
# tmux-mem-cpu-load, prefix-highlight, gitmux, tmux-acpi, clock) as powerline
# segments instead of literal status-left/status-right strings.

export TMUX_POWERLINE_DIR_USER_SEGMENTS="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline/segments"

export TMUX_POWERLINE_STATUS_JUSTIFICATION="centre"
export TMUX_POWERLINE_STATUS_INTERVAL="1"
# Generous budgets: tmux counts the raw #[...] style-code bytes toward this
# length, not just visible characters, so powerline-styled segments need much
# more room than their visible width suggests (60/100 was clipping mid-escape-
# sequence, dropping load averages and leaving cpu% unstyled).
export TMUX_POWERLINE_STATUS_LEFT_LENGTH="400"
export TMUX_POWERLINE_STATUS_RIGHT_LENGTH="300"

# SteamOS palette (previously status-style bg/fg).
export TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR="#0E1419"
export TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR="#00BFFF"

# Session-info segment: session name only (previously #{session_name}).
export TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT="#S"

# tmux-mem-cpu-load segment. -p draws its own powerline-style separators/colors
# between mem, cpu%, and load; -g 0 disables the plain ASCII "[ ]" cpu-history
# bar (empty/unappealing at low load) in favor of just the cpu% number.
export TMUX_POWERLINE_SEG_TMUX_MEM_CPU_LOAD_ARGS="-p -g 0 --interval 2 -l 39"

# Window tabs, unchanged from the previous window-status-format /
# window-status-current-format.
TMUX_POWERLINE_WINDOW_STATUS_FORMAT=(
	"#[bg=#1a2332,fg=#00BFFF]"
	" #W "
)
TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
	"#[bg=#00BFFF,fg=#0E1419,bold]"
	" #W "
	"#[default]"
)

# tmux_session_info's own separator (the arrow after it, into tmux_mem_cpu_load)
# is disabled -- tmux_mem_cpu_load's raw -p output already draws its own
# leading arrow (blended from colour39, via the -l 39 flag in
# TMUX_POWERLINE_SEG_TMUX_MEM_CPU_LOAD_ARGS, into its own colour180 block).
# Leaving tmux-powerline's separator enabled here draws a second, unrelated
# arrow right before that one instead of a single clean transition.
TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
	"tmux_session_info #00BFFF #0E1419 default_separator no_sep_bg_color no_sep_fg_color no_spacing_disable separator_disable"
	"tmux_mem_cpu_load colour72 colour72 default_separator no_sep_bg_color no_sep_fg_color both_disable separator_disable"
)

TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
	"prefix_highlight default_bg_color default_fg_color default_separator no_sep_bg_color no_sep_fg_color no_spacing_disable separator_disable"
	"git_status default_bg_color default_fg_color default_separator no_sep_bg_color no_sep_fg_color no_spacing_disable separator_disable"
	"power_status #cccccc #0E1419"
	"date_time #00BFFF #0E1419"
)
