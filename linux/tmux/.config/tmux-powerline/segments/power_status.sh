# shellcheck shell=bash
# Show tmux-acpi adapter/battery status (previously
# "POW: #{acpi_adapter} | #{acpi_battery}" in status-right).

run_segment() {
	echo "POW: #{acpi_adapter} | #{acpi_battery}"
	return 0
}
