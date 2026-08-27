# shellcheck shell=bash
# Show the tmux-prefix-highlight indicator (previously #{prefix_highlight}
# embedded directly in status-right).

run_segment() {
	echo "#{prefix_highlight}"
	return 0
}
