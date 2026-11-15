#!/bin/sh
#
# prompt-gap-fixtures.sh -- #270 prompt separator contract.
#
# Asserts, under a real pty running a real interactive shell:
#   1. the FIRST prompt of a shell process has no blank line above it
#   2. a prompt following an executed command has one blank line above it
#   3. a prompt following a bare Enter has one blank line above it
#   4. a prompt following a Ctrl-C has one blank line above it
#   5. a prompt following `clear` has NO blank line above it
#   6. a prompt following a bare Enter AFTER a clear has one blank line above it
#   7. a prompt following a Ctrl-C AFTER a clear has one blank line above it
#   8. a prompt following a command AFTER a clear has one blank line above it
#
# Assertions 6-8 are not padding. A state machine exercised only up to its
# reset asserts nothing about the state the reset leaves behind: an earlier
# draft stopped driving at `clear` and passed a bash implementation whose
# disarm latched on forever. Do not shorten the driven sequence.
#
# Contract and rationale: issue #270, ADR-0003 (prompt separator ownership).
#
# precmd/PROMPT_COMMAND only run in INTERACTIVE shells, so `zsh -c` asserts
# nothing here: every case runs `zsh -i` / `bash -i` under script(1).

set -eu

FIXTURE_FAILED=0
FIXTURE_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd "$FIXTURE_DIR/../.." && pwd)

STARSHIP_TOML="$REPO_ROOT/linux/starship/.config/starship.toml"
ZSH_FRAGMENT="$REPO_ROOT/linux/zsh/.zsh/prompt-gap.zsh"
BASH_FRAGMENT="$REPO_ROOT/linux/bash/.bashrc.d/04-starship"
BLEND_DIR="$REPO_ROOT/linux/starship/.local/bin"

ANCHOR=promptgap

# Missing tooling must be LOUD. A silent skip is how a guard lands green
# without ever running (see #270 design doc, "Vacuous-green traps").
require_tool() {
  if command -v "$1" >/dev/null 2>&1; then
    return 0
  fi
  if [ "${PROMPT_GAP_ALLOW_SKIP:-0}" = "1" ]; then
    printf '[prompt-gap] SKIP: %s not installed (PROMPT_GAP_ALLOW_SKIP=1)\n' "$1"
    exit 0
  fi
  printf '[prompt-gap] FATAL: %s not installed; this suite cannot assert anything without it\n' "$1" >&2
  exit 1
}

SCRIPT_STYLE=""
detect_script_style() {
  if script -qec "true" /dev/null >/dev/null 2>&1; then
    SCRIPT_STYLE=gnu
  else
    SCRIPT_STYLE=bsd
  fi
}

# Turn a script(1) capture into the sequence of rendered visual lines:
# drop OSC/CSI escapes and backspaces, drop the CR of each CRLF, then keep
# only the text after the last remaining CR (an in-line repaint wins).
normalize() {
  LC_ALL=C sed -e 's/\x1b\][^\x07]*\x07//g' \
               -e 's/\x1b\[[0-9;?]*[a-zA-Z]//g' \
               -e 's/\x1b[=>]//g' \
               -e 's/\x1b.//g' \
    | tr -d '\010' \
    | LC_ALL=C sed -e 's/\r*$//' \
    | LC_ALL=C awk '{ n = split($0, p, "\r"); line = p[n]; sub(/[ \t]+$/, "", line); print line }'
}

# Paced keystrokes. Real sleeps, not a here-doc: input piped in one burst is
# echoed by the pty before the first prompt is drawn, which would put text
# above prompt 1 and make assertion 1 untestable.
drive_keystrokes() {
  sleep 1
  printf 'echo GAPMARK\n'; sleep 1
  printf '\n'; sleep 1
  printf 'sleep 5'; sleep 1; printf '\n'; sleep 1; printf '\003'; sleep 1
  printf 'clear\n'; sleep 1
  printf '\n'; sleep 1
  printf 'abandoned'; sleep 1; printf '\003'; sleep 1
  printf 'echo TAIL\n'; sleep 1
  printf 'exit\n'; sleep 1
}

# Build a launcher rather than interpolating env assignments into the
# script(1) command string: paths with spaces (or a stray quote) would
# otherwise silently break the child, and a broken child looks exactly like
# a shell that rendered no prompts.
#
# PATH is minimal and explicit, not inherited. An inherited PATH drags in
# whatever language toolchains the host happens to have, and starship's
# $all renders a module for each -- so the prompt content, and therefore
# the capture, would differ between developer machines and CI.
#
# TMUX is set because linux/systems/.profile:182 and
# linux/bash/.bashrc.d/02-tmux:2 would otherwise run `tmux attach || tmux
# new` and swallow the pty. Their other guard, TMUX_DISABLE_AT_BOOT, is
# inverted AND re-exported by .profile:96-100, so exporting it from outside
# does nothing. TMUX is the only guard the fixture can actually hold.
#
# $1 launcher path, $2 sandbox HOME, $3 shell invocation
write_launcher() {
  _tool_dir=$(dirname "$(command -v starship)")
  cat > "$1" <<EOF
#!/bin/sh
PATH="$BLEND_DIR:$_tool_dir:/usr/local/bin:/usr/bin:/bin"
HOME="$2"
TERM=xterm-256color
LANG=C.UTF-8
TMUX=/dev/null,0,0
STARSHIP_CONFIG="$STARSHIP_TOML"
export PATH HOME TERM LANG TMUX STARSHIP_CONFIG
unset VIRTUAL_ENV CONDA_DEFAULT_ENV
exec $3
EOF
  chmod +x "$1"
}

# $1 capture file, $2 launcher path
capture_session() {
  if [ "$SCRIPT_STYLE" = "gnu" ]; then
    drive_keystrokes | script -qec "sh $2" /dev/null > "$1" 2>&1 || true
  else
    drive_keystrokes | script -q /dev/null sh "$2" > "$1" 2>&1 || true
  fi
}

# Line number of the Nth prompt. A prompt is identified by its $directory
# pill, which always renders and always carries the sandbox directory name.
anchor_line() {
  LC_ALL=C grep -n -F "$ANCHOR" "$1" | sed -n "${2}p" | cut -d: -f1
}

line_at() {
  sed -n "${2}p" "$1"
}

assert_gap_above() {
  _norm="$1"; _nth="$2"; _want="$3"; _label="$4"
  _ln=$(anchor_line "$_norm" "$_nth")
  if [ -z "$_ln" ]; then
    printf '[prompt-gap] %s ... FAIL: prompt #%s never rendered\n' "$_label" "$_nth" >&2
    return 1
  fi
  if [ "$_want" = "first" ]; then
    if [ "$_ln" = "1" ]; then return 0; fi
    printf '[prompt-gap] %s ... FAIL: first prompt is at line %s, expected line 1 (blank above it)\n' "$_label" "$_ln" >&2
    return 1
  fi
  _above=$(line_at "$_norm" $((_ln - 1)))
  if [ "$_want" = "blank" ]; then
    if [ -z "$_above" ]; then return 0; fi
    printf '[prompt-gap] %s ... FAIL: expected a blank separator above prompt #%s, got [%s]\n' "$_label" "$_nth" "$_above" >&2
    return 1
  fi
  if [ -n "$_above" ]; then return 0; fi
  printf '[prompt-gap] %s ... FAIL: unexpected blank separator above prompt #%s\n' "$_label" "$_nth" >&2
  return 1
}

# AC-005 must not be satisfied by a "command not found: clear" message: that is
# non-empty text above the prompt while the screen was never wiped. require_tool
# clear is the primary guard; this is the second line of defence.
assert_line_above_is_clear_echo() {
  _norm="$1"; _nth="$2"; _label="$3"
  _ln=$(anchor_line "$_norm" "$_nth")
  if [ -z "$_ln" ]; then
    printf '[prompt-gap] %s ... FAIL: prompt #%s never rendered\n' "$_label" "$_nth" >&2
    return 1
  fi
  _above=$(line_at "$_norm" $((_ln - 1)))
  if printf '%s\n' "$_above" | LC_ALL=C grep -q 'not found'; then
    printf '[prompt-gap] %s ... FAIL: `clear` did not run: [%s]\n' "$_label" "$_above" >&2
    return 1
  fi
  if printf '%s\n' "$_above" | LC_ALL=C grep -Fq 'clear'; then return 0; fi
  printf '[prompt-gap] %s ... FAIL: expected the echoed `clear` above prompt #%s, got [%s]\n' "$_label" "$_nth" "$_above" >&2
  return 1
}

run_case() {
  _name="$1"; shift
  if "$@"; then
    printf '[prompt-gap] %s ... PASS\n' "$_name"
  else
    FIXTURE_FAILED=1
  fi
}

case_config_add_newline() {
  if LC_ALL=C grep -Eq '^[[:space:]]*add_newline[[:space:]]*=[[:space:]]*false' "$STARSHIP_TOML"; then
    return 0
  fi
  printf '[prompt-gap] config: starship.toml must set add_newline = false ... FAIL\n' >&2
  return 1
}

case_zsh_gap() {
  _root="$1"
  _home="$_root/zsh-home"; mkdir -p "$_home/$ANCHOR"
  cat > "$_home/.zshrc" <<EOF
autoload -Uz add-zsh-hook
eval "\$(starship init zsh)"
PROMPT='\$(starship prompt --terminal-width="\$COLUMNS" --keymap="\${KEYMAP:-}" --status="\${STARSHIP_CMD_STATUS:-}" --pipestatus="\${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="\${STARSHIP_DURATION:-}" --jobs="\$STARSHIP_JOBS_COUNT" | starship-blend left)'
RPROMPT='\$(starship prompt --right --terminal-width="\$COLUMNS" --keymap="\${KEYMAP:-}" --status="\${STARSHIP_CMD_STATUS:-}" --pipestatus="\${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="\${STARSHIP_DURATION:-}" --jobs="\$STARSHIP_JOBS_COUNT" | starship-blend right)'
ZLE_RPROMPT_INDENT=0
cd "$_home/$ANCHOR"
[ -r "$ZSH_FRAGMENT" ] && source "$ZSH_FRAGMENT"
EOF
  _raw="$_root/zsh.raw"; _norm="$_root/zsh.norm"
  write_launcher "$_root/launch-zsh.sh" "$_home" "env ZDOTDIR=$_home zsh -i"
  capture_session "$_raw" "$_root/launch-zsh.sh"
  normalize < "$_raw" > "$_norm"

  _st=0
  assert_gap_above "$_norm" 1 first  "zsh: first prompt has no blank above"       || _st=1
  assert_gap_above "$_norm" 2 blank  "zsh: post-command prompt has blank above"   || _st=1
  assert_gap_above "$_norm" 3 blank  "zsh: post-bare-Enter prompt has blank above" || _st=1
  assert_gap_above "$_norm" 4 blank  "zsh: post-Ctrl-C prompt has blank above"    || _st=1
  assert_line_above_is_clear_echo "$_norm" 5 "zsh: post-clear prompt has no blank above" || _st=1
  assert_gap_above "$_norm" 6 blank  "zsh: first bare Enter AFTER a clear has blank above"  || _st=1
  assert_gap_above "$_norm" 7 blank  "zsh: first Ctrl-C AFTER a clear has blank above"      || _st=1
  assert_gap_above "$_norm" 8 blank  "zsh: post-clear tail command has blank above"         || _st=1
  [ "$_st" -eq 0 ] || cat -A "$_norm" >&2
  return "$_st"
}

case_bash_gap() {
  _root="$1"
  _home="$_root/bash-home"; mkdir -p "$_home/$ANCHOR"
  # Ubuntu/Debian ship a /etc/bash.bashrc that prints a sudo hint above the
  # first prompt. --rcfile does not suppress the system rc, and any output
  # there sits exactly where assertion 1 looks. These two markers are the
  # documented opt-outs.
  : > "$_home/.sudo_as_admin_successful"
  : > "$_home/.hushlogin"
  cat > "$_home/.bashrc" <<EOF
cd "$_home/$ANCHOR"
source "$BASH_FRAGMENT"
EOF
  _raw="$_root/bash.raw"; _norm="$_root/bash.norm"
  write_launcher "$_root/launch-bash.sh" "$_home" "bash --rcfile $_home/.bashrc -i"
  capture_session "$_raw" "$_root/launch-bash.sh"
  normalize < "$_raw" > "$_norm"

  _st=0
  assert_gap_above "$_norm" 1 first  "bash: first prompt has no blank above"       || _st=1
  assert_gap_above "$_norm" 2 blank  "bash: post-command prompt has blank above"   || _st=1
  assert_gap_above "$_norm" 3 blank  "bash: post-bare-Enter prompt has blank above" || _st=1
  assert_gap_above "$_norm" 4 blank  "bash: post-Ctrl-C prompt has blank above"    || _st=1
  assert_line_above_is_clear_echo "$_norm" 5 "bash: post-clear prompt has no blank above" || _st=1
  assert_gap_above "$_norm" 6 blank  "bash: first bare Enter AFTER a clear has blank above"  || _st=1
  assert_gap_above "$_norm" 7 blank  "bash: first Ctrl-C AFTER a clear has blank above"      || _st=1
  assert_gap_above "$_norm" 8 blank  "bash: post-clear tail command has blank above"         || _st=1
  [ "$_st" -eq 0 ] || cat -A "$_norm" >&2
  return "$_st"
}

main() {
  require_tool script
  require_tool starship
  require_tool zsh
  require_tool bash
  require_tool clear   # AC-005 drives it; without it the screen is never wiped

  _tmp=$(mktemp -d)
  trap 'rm -rf "$_tmp"' EXIT
  detect_script_style

  run_case "config: starship.toml sets add_newline = false" case_config_add_newline
  run_case "zsh: prompt separator contract" case_zsh_gap "$_tmp"
  run_case "bash: prompt separator contract" case_bash_gap "$_tmp"

  if [ "$FIXTURE_FAILED" -eq 1 ]; then
    printf '[prompt-gap] RESULT: FAIL\n' >&2
    exit 1
  fi
  printf '[prompt-gap] RESULT: PASS\n'
  exit 0
}

main
