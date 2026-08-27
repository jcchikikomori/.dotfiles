# shellcheck shell=bash
# Show the clock (previously "%a %h-%d %H:%M:%S" in status-right).

run_segment() {
	date +"%a %h-%d %H:%M:%S"
	return 0
}
