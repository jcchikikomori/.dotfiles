# shellcheck shell=bash
# Show gitmux output for the current pane's path (previously
# #(gitmux -cfg $HOME/.gitmux.conf "#{pane_current_path}") in status-right).
# Falls back to no output when gitmux isn't installed.

# shellcheck source=lib/tmux_adapter.sh
source "${TMUX_POWERLINE_DIR_LIB}/tmux_adapter.sh"

run_segment() {
	if ! command -v gitmux >/dev/null 2>&1; then
		return 0
	fi

	local tmux_path
	tmux_path=$(tp_get_tmux_cwd)
	gitmux -cfg "$HOME/.gitmux.conf" "$tmux_path"
	return 0
}
