#!/bin/sh
#
# prompt-gap-fixtures.sh -- #270 prompt separator contract.
#
# Asserts, under a real pty running a real interactive shell:
#    1. the FIRST prompt of a shell process has no blank line above it
#    2. a prompt following an executed command has one blank line above it
#    3. a prompt following a bare Enter has one blank line above it
#    4. a prompt following a Ctrl-C has one blank line above it
#    5. a prompt following `clear` has NO blank line above it
#    6. a prompt following a bare Enter AFTER a clear has one blank line above it
#    7. a prompt following a Ctrl-C AFTER a clear has one blank line above it
#    8. a prompt following a command AFTER a clear has one blank line above it
#    9. a prompt following a history reset has one blank line above it
#   10. a prompt following `clear` AFTER a history reset has NO blank line
#       above it  -- the bash disarm must gate on the history index being
#       DIFFERENT, not greater; see below
#   11. a prompt following a re-source of the rc has one blank line above it
#   12. a prompt following a command after that re-source has one blank above
#   13. (bash only) the capture still contains powerline wedges, i.e.
#       starship-blend is still on the bash render path
#
# "One blank line" means EXACTLY one. At-least-one would miss a doubled
# separator, and doubling is a live regression path: re-sourcing ~/.bashrc in a
# running shell re-wraps the already-wrapped starship_precmd.
#
# Assertions 6-8 are not padding. A state machine exercised only up to its
# reset asserts nothing about the state the reset leaves behind: an earlier
# draft stopped driving at `clear` and passed a bash implementation whose
# disarm latched on forever. Do not shorten the driven sequence.
#
# Assertion 10 exists because `history -c` is the ONLY way to observe the
# difference between `!=` and `>` in the bash disarm's index gate. Without a
# history reset in the driven sequence the index only ever increases, both
# operators agree on every prompt, and mutating one into the other leaves the
# whole suite green -- which is exactly what happened before this was added.
#
# Assertions 11-12 exist because the armed flag used to be assigned
# unconditionally, so `source ~/.zshrc` -- routine right after editing the rc --
# reset it and cost the next prompt its separator. Measured, both shells.
#
# Contract and rationale: issue #270, ADR-0003 (prompt separator ownership).
#
# precmd/PROMPT_COMMAND only run in INTERACTIVE shells, so `zsh -c` asserts
# nothing here: every case runs `zsh -i` / `bash -i` under script(1).

# SC2329 is "this function is never invoked". Every case and helper here is
# dispatched indirectly -- `run_case "$_name" "$@"` for the cases, and the
# expectation table for the assertions -- so shellcheck cannot see the call
# graph and reports all sixteen of them. Its own message allows for this: "or
# ignored if invoked indirectly". Disabled file-wide rather than sixteen times,
# because the cause is one design decision, not sixteen; a per-function pragma
# would also have to be re-added by hand for every helper added later.
# shellcheck disable=SC2329

set -eu

FIXTURE_FAILED=0
# SC1007 reads `CDPATH= cd ...` as a botched assignment. It is a POSIX one-shot
# environment assignment prefixing a command, which is the documented way to
# stop CDPATH from making `cd` print its destination. Removing the space, as
# the warning suggests, would assign the string "cd".
# shellcheck disable=SC1007
FIXTURE_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
# shellcheck disable=SC1007
REPO_ROOT=$(CDPATH= cd "$FIXTURE_DIR/../.." && pwd)

STARSHIP_TOML="$REPO_ROOT/linux/starship/.config/starship.toml"
ZSH_FRAGMENT="$REPO_ROOT/linux/zsh/.zsh/prompt-gap.zsh"
BASH_FRAGMENT="$REPO_ROOT/linux/bash/.bashrc.d/04-starship"
BLEND_DIR="$REPO_ROOT/linux/starship/.local/bin"

ANCHOR=promptgap

# Seconds to wait for a shell's FIRST prompt before giving up. Generous on
# purpose: this is a ceiling for a broken shell, not a pacing knob. The normal
# path polls and proceeds as soon as the prompt is up.
FIRST_PROMPT_TIMEOUT=20

# U+E0B0, the powerline wedge. starship-blend is the only thing on this render
# path that emits it: raw `starship prompt` output contains none. Assertion 9
# uses it to notice a wrapper rebuilt without the blend pipe.
WEDGE=$(printf '\356\202\260')

# The child shell runs on this PATH, not on the ambient one. require_tool probes
# the same PATH the child will use, so a binary only the outer shell can see
# cannot satisfy a guard for a tool the child then fails to find.
MINIMAL_PATH=""

# Missing tooling must be LOUD. A silent skip is how a guard lands green
# without ever running (see #270 design doc, "Vacuous-green traps").
# $1 tool, $2 optional PATH to probe (defaults to the ambient PATH). The probe
# runs in a subshell so the override cannot leak into the caller.
require_tool() {
  if (PATH="${2:-$PATH}"; export PATH; command -v "$1" >/dev/null 2>&1); then
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
#
# The control bytes are built with printf rather than written as \x1b/\x07/\r
# inside the sed expressions. Those escapes are a GNU sed extension: BSD sed,
# which is what macOS ships, passes them through as the literal two characters
# and the whole normaliser silently stops stripping anything. This file already
# branches for BSD script(1), so promising macOS support and then using
# GNU-only regex escapes was a half-promise. Same idiom as
# output-lib-fixtures.sh, the file this suite's structure was copied from.
normalize() {
  _esc=$(printf '\033')
  _bel=$(printf '\007')
  _cr=$(printf '\r')
  _bs=$(printf '\010')
  LC_ALL=C sed -e "s/${_esc}\][^${_bel}]*${_bel}//g" \
               -e "s/${_esc}\[[0-9;?]*[a-zA-Z]//g" \
               -e "s/${_esc}[=>]//g" \
               -e "s/${_esc}.//g" \
    | tr -d "$_bs" \
    | LC_ALL=C sed -e "s/${_cr}*\$//" \
    | LC_ALL=C awk -v cr='\r' '{ n = split($0, p, cr); line = p[n]; sub(/[ \t]+$/, "", line); print line }'
}

# Wait until the first prompt is actually on screen, rather than guessing how
# long that takes.
#
# Measured, 7 cold starts each: bash's first prompt lands in 0.03-0.41s, zsh's
# in 1.31-2.56s (median 1.78s) -- a cold `starship prompt` render dominates.
# This used to be a flat `sleep 1`, so the margin against zsh was NEGATIVE at
# the median and the suite raced the shell on every run. It lost: the first
# keystroke was echoed by the tty driver while zsh was still in canonical mode,
# putting `echo GAPMARK` above prompt 1 and failing AC-001 -- exactly the
# failure the pacing exists to prevent.
#
# The concurrent script(1) writes the capture as it goes (first bytes land
# within ~200ms), so the driver can watch the same file the assertions will
# later read. A CI runner slower than the development machine now waits longer
# instead of failing; a faster one starts sooner.
#
# Whole-second polling, not fractional: POSIX only requires `sleep` to accept
# an integer, and this file has to run on macOS and Termux too.
#
# The timeout message is a DIAGNOSTIC, not the gate. Its return value is
# discarded by the pipeline in capture_session, and deliberately so: if a shell
# genuinely never prompts, every assertion fails on "prompt #N never rendered"
# and the suite is already red. This line exists to say WHY, so the next reader
# does not go looking for a normaliser bug. The timeout is set far above any
# real first-prompt latency precisely so that reaching it means something is
# broken rather than slow.
#
# $1 capture file the concurrent script(1) is writing
wait_for_first_prompt() {
  _waited=0
  while [ "$_waited" -le "$FIRST_PROMPT_TIMEOUT" ]; do
    if LC_ALL=C grep -q "$ANCHOR" "$1" 2>/dev/null; then
      # The anchor sits mid-prompt; let the rest of the line paint before
      # typing into it.
      sleep 1
      return 0
    fi
    sleep 1
    _waited=$((_waited + 1))
  done
  printf '[prompt-gap] FATAL: no prompt within %ss of shell start (capture is %s bytes)\n' \
    "$FIRST_PROMPT_TIMEOUT" "$(wc -c < "$1" 2>/dev/null || echo 0)" >&2
  return 1
}

# Paced keystrokes. Real sleeps, not a here-doc: input piped in one burst is
# echoed by the pty before the first prompt is drawn, which would put text
# above prompt 1 and make assertion 1 untestable.
#
# $2 is the capture file, watched by wait_for_first_prompt so the opening wait
# is a readiness check rather than a guess. Every LATER sleep is still a flat
# second: those were tuned against measured pty echo timing and have never
# raced -- only the opening one had a shell cold start to lose to.
#
# $1 is the shell name, and it changes exactly ONE step. Prompts 1-8 are the
# cross-shell parity sequence (AC-006) and are byte-identical in both shells.
#
# Step 9 is the history-index regression guard, and only bash can have one:
# `history -c` is a bash builtin, while zsh's `history` is `fc -l`, which has no
# -c and would print `fc: bad option` straight into the row assertion 9
# inspects. zsh drives `true` instead -- a shape-preserving stand-in that keeps
# both shells on the same prompt indices, so the expectation table stays
# single-sourced. zsh has no history index to gate on, so there is nothing for
# it to guard; its assertions at 9-10 are the control showing the two extra
# steps do not perturb the shell that is already correct.
#
# $1 also names the rc at step 11 (`. ~/.zshrc` / `. ~/.bashrc`). Written with
# `~` rather than the absolute sandbox path on purpose: the absolute path is
# long enough to wrap at narrow terminal widths, and a wrapped echo would put a
# second visual line where assertion 11 looks for the separator.
drive_keystrokes() {
  wait_for_first_prompt "$2"
  printf 'echo GAPMARK\n'; sleep 1
  printf '\n'; sleep 1
  printf 'sleep 5'; sleep 1; printf '\n'; sleep 1; printf '\003'; sleep 1
  printf 'clear\n'; sleep 1
  printf '\n'; sleep 1
  printf 'abandoned'; sleep 1; printf '\003'; sleep 1
  printf 'echo TAIL\n'; sleep 1
  if [ "$1" = bash ]; then printf 'history -c\n'; else printf 'true\n'; fi; sleep 1
  printf 'clear\n'; sleep 1
  printf '. ~/.%src\n' "$1"; sleep 2
  printf 'echo AFTER\n'; sleep 1
  printf 'exit\n'; sleep 1
}

# Resolve the child's PATH once. starship's own directory is prepended, so the
# binary this process located is the binary the child runs -- no version skew
# between what require_tool probed and what rendered the prompt.
init_minimal_path() {
  _tool_dir=$(dirname "$(command -v starship)")
  MINIMAL_PATH="$BLEND_DIR:$_tool_dir:/usr/local/bin:/usr/bin:/bin"
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
  cat > "$1" <<EOF
#!/bin/sh
PATH="$MINIMAL_PATH"
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

# $1 capture file, $2 launcher path, $3 shell name (drives the one shell-specific
# step and names the rc to re-source)
# SC2094 ("read and write the same file in the same pipeline") is CORRECT here,
# not a false positive, and the overlap is the mechanism rather than a mistake:
# drive_keystrokes polls the capture that script(1) is concurrently appending
# to, which is how it knows the first prompt is on screen instead of guessing.
# script(1) only ever appends and the driver only ever greps, so there is no
# write-write race and no truncation mid-run -- the single truncation is the
# `: > "$1"` below, before either side starts.
capture_session() {
  : > "$1"
  if [ "$SCRIPT_STYLE" = "gnu" ]; then
    # shellcheck disable=SC2094
    drive_keystrokes "$3" "$1" | script -qec "sh '$2'" /dev/null > "$1" 2>&1 || true
  else
    # shellcheck disable=SC2094
    drive_keystrokes "$3" "$1" | script -q /dev/null sh "$2" > "$1" 2>&1 || true
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
    if [ -n "$_above" ]; then
      printf '[prompt-gap] %s ... FAIL: expected a blank separator above prompt #%s, got [%s]\n' "$_label" "$_nth" "$_above" >&2
      return 1
    fi
    # EXACTLY one blank, not at least one. Checking only line _ln-1 would pass a
    # doubled separator, and doubling is reachable: re-sourcing ~/.bashrc wraps
    # the already-wrapped starship_precmd, doubling both the gap and the blend.
    # A guard whose whole purpose is deleting wasted rows must see that.
    if [ "$_ln" -le 2 ]; then return 0; fi
    _above2=$(line_at "$_norm" $((_ln - 2)))
    if [ -z "$_above2" ]; then
      printf '[prompt-gap] %s ... FAIL: more than one blank separator above prompt #%s\n' "$_label" "$_nth" >&2
      return 1
    fi
    return 0
  fi
  # No silent fallthrough. This function accepts exactly two expectations; a
  # third value reaching here means the table has a typo, and a typo that
  # quietly asserts nothing reads as green.
  printf '[prompt-gap] %s ... FAIL: assert_gap_above accepts first|blank, got [%s]\n' "$_label" "$_want" >&2
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
    # SC2016 sees backticks in a single-quoted string and assumes a thwarted
    # command substitution. They are literal prose in a failure message, marking
    # up the command name the way the rest of this file's comments do.
    # shellcheck disable=SC2016
    printf '[prompt-gap] %s ... FAIL: `clear` did not run: [%s]\n' "$_label" "$_above" >&2
    return 1
  fi
  if printf '%s\n' "$_above" | LC_ALL=C grep -Fq 'clear'; then return 0; fi
  # Literal backticks in prose, as above.
  # shellcheck disable=SC2016
  printf '[prompt-gap] %s ... FAIL: expected the echoed `clear` above prompt #%s, got [%s]\n' "$_label" "$_nth" "$_above" >&2
  return 1
}

# ADR-0003 names "rebuilding rather than extending the wrapper silently drops
# starship-blend (regressing #248/#251/#258/#265)" among the biggest risks, and
# the wrapper is exactly what this change edits. Every prompt anchor is the
# $directory pill, which renders with or without the blend, so a dropped blend
# is invisible to all the other assertions. This is the Design Doc's
# "Integration Verification Points" check, made executable.
assert_blend_on_render_path() {
  _norm="$1"; _label="$2"
  if LC_ALL=C grep -q "$WEDGE" "$_norm"; then return 0; fi
  printf '[prompt-gap] %s ... FAIL: no U+E0B0 wedge in the capture; starship-blend is no longer on the bash render path\n' "$_label" >&2
  return 1
}

# The AC -> prompt -> expectation table, single-sourced for BOTH shells.
#
# AC-006 *is* "the same gap/no-gap decision at every prompt in both shells".
# Two hand-maintained copies of this table would leave the one property the
# suite exists to assert enforced by nothing but the discipline of whoever
# edits it next -- and the two lists must be identical by construction, so
# there is no "the mechanisms differ" argument for keeping them apart the way
# there is for the zsh and bash hooks themselves.
#
# Fields: prompt-index  expectation  AC  description
prompt_expectations() {
  cat <<'EOF'
1 first AC-001 first prompt has no blank above
2 blank AC-002 post-command prompt has blank above
3 blank AC-004 post-bare-Enter prompt has blank above
4 blank AC-003 post-Ctrl-C prompt has blank above
5 clearecho AC-005 post-clear prompt has no blank above
6 blank AC-004b first bare Enter AFTER a clear has blank above
7 blank AC-003b first Ctrl-C AFTER a clear has blank above
8 blank AC-002b post-clear tail command has blank above
9 blank AC-009 post-history-reset prompt has blank above
10 clearecho AC-010 post-clear prompt AFTER a history reset has no blank above
11 blank AC-011 prompt after an rc re-source has blank above
12 blank AC-012 prompt after a command following an rc re-source has blank above
EOF
}

# Dispatch on the table's expectation column. An unrecognised value is a LOUD
# failure, never a silent skip.
assert_prompt() {
  _pnorm="$1"; _pnth="$2"; _pwant="$3"; _plabel="$4"
  case "$_pwant" in
    first|blank) assert_gap_above "$_pnorm" "$_pnth" "$_pwant" "$_plabel" ;;
    clearecho)   assert_line_above_is_clear_echo "$_pnorm" "$_pnth" "$_plabel" ;;
    *)
      printf '[prompt-gap] %s ... FAIL: unrecognised expectation [%s]; the table accepts first|blank|clearecho\n' "$_plabel" "$_pwant" >&2
      return 1
      ;;
  esac
}

# Run the whole table against one shell's normalised capture.
# The here-doc redirect (not a pipe) keeps the loop in this shell, so the
# accumulated status survives it.
# $1 normalised capture, $2 shell name
assert_prompt_table() {
  _tnorm="$1"; _tshell="$2"; _tst=0
  while read -r _tnth _twant _tac _tdesc; do
    [ -n "$_tnth" ] || continue
    assert_prompt "$_tnorm" "$_tnth" "$_twant" "$_tac $_tshell: $_tdesc" || _tst=1
  done <<EOF
$(prompt_expectations)
EOF
  return "$_tst"
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
  printf '[prompt-gap] AC-007 config: starship.toml must set add_newline = false ... FAIL\n' >&2
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
if [ -r "$ZSH_FRAGMENT" ]; then source "$ZSH_FRAGMENT"; fi
EOF
  _raw="$_root/zsh.raw"; _norm="$_root/zsh.norm"
  write_launcher "$_root/launch-zsh.sh" "$_home" "env ZDOTDIR='$_home' zsh -i"
  capture_session "$_raw" "$_root/launch-zsh.sh" zsh
  normalize < "$_raw" > "$_norm"

  _st=0
  assert_prompt_table "$_norm" zsh || _st=1
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
  write_launcher "$_root/launch-bash.sh" "$_home" "bash --rcfile '$_home/.bashrc' -i"
  capture_session "$_raw" "$_root/launch-bash.sh" bash
  normalize < "$_raw" > "$_norm"

  _st=0
  assert_prompt_table "$_norm" bash || _st=1
  assert_blend_on_render_path "$_norm" "IVP bash: starship-blend still on the render path" || _st=1
  [ "$_st" -eq 0 ] || cat -A "$_norm" >&2
  return "$_st"
}

main() {
  # script(1) and starship are resolved by THIS process: script runs here, and
  # starship's directory is located here and then pinned into MINIMAL_PATH.
  require_tool script
  require_tool starship
  init_minimal_path
  # zsh, bash and clear run inside the child, so they are probed on the child's
  # PATH. Probing the ambient PATH instead lets a binary the child never sees
  # satisfy the guard.
  require_tool zsh "$MINIMAL_PATH"
  require_tool bash "$MINIMAL_PATH"
  require_tool clear "$MINIMAL_PATH"   # AC-005 drives it; without it the screen is never wiped

  _tmp=$(mktemp -d)
  trap 'rm -rf "$_tmp"' EXIT
  detect_script_style

  run_case "AC-007 config: starship.toml sets add_newline = false" case_config_add_newline
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
