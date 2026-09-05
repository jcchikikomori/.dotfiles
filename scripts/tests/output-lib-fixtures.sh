#!/bin/sh

set -eu

FIXTURE_FAILED=0

BIN="${DOTFILES_BIN:-}"
FIXTURE_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd "$FIXTURE_DIR/../.." && pwd)
if [ -z "$BIN" ]; then
  BIN="$REPO_ROOT/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin"
fi

LIB="$BIN/dotfiles-lib-output"
if [ ! -r "$LIB" ]; then
  printf '[fixture] FATAL: library not found at %s\n' "$LIB" >&2
  exit 1
fi

. "$LIB"

assert_eq() {
  expected="$1"
  actual="$2"
  label="$3"
  if [ "$expected" = "$actual" ]; then
    return 0
  fi
  printf '[fixture] %s ... FAIL: expected [%s], got [%s]\n' "$label" "$expected" "$actual" >&2
  return 1
}

assert_contains() {
  needle="$1"
  haystack="$2"
  label="$3"
  if printf '%s\n' "$haystack" | LC_ALL=C grep -Fq "$needle"; then
    return 0
  fi
  printf '[fixture] %s ... FAIL: [%s] not found\n' "$label" "$needle" >&2
  return 1
}

assert_not_contains() {
  needle="$1"
  haystack="$2"
  label="$3"
  if printf '%s\n' "$haystack" | LC_ALL=C grep -Fq "$needle"; then
    printf '[fixture] %s ... FAIL: unexpected [%s] found\n' "$label" "$needle" >&2
    return 1
  fi
  return 0
}

assert_bytes_clean() {
  file="$1"
  label="$2"
  cr=$(printf '\r')
  esc=$(printf '\033')
  if LC_ALL=C grep -q "$cr" "$file" || LC_ALL=C grep -q "$esc" "$file"; then
    printf '[fixture] %s ... FAIL: output contains CR/ESC bytes\n' "$label" >&2
    return 1
  fi
  return 0
}

assert_has_esc() {
  file="$1"
  label="$2"
  esc=$(printf '\033')
  if LC_ALL=C grep -q "$esc" "$file"; then
    return 0
  fi
  printf '[fixture] %s ... FAIL: no ESC byte found\n' "$label" >&2
  return 1
}

assert_no_esc() {
  file="$1"
  label="$2"
  esc=$(printf '\033')
  if LC_ALL=C grep -q "$esc" "$file"; then
    printf '[fixture] %s ... FAIL: unexpected ESC byte found\n' "$label" >&2
    return 1
  fi
  return 0
}

assert_success() {
  label="$1"
  shift
  if "$@"; then
    return 0
  fi
  printf '[fixture] %s ... FAIL: command exited non-zero\n' "$label" >&2
  return 1
}

run_case() {
  name="$1"
  shift
  if "$@"; then
    printf '[fixture] %s ... PASS\n' "$name"
  else
    FIXTURE_FAILED=1
  fi
}

create_mock_commands() {
  mock_dir="$1"
  mkdir -p "$mock_dir"

  cat > "$mock_dir/stty" <<'EOF'
#!/bin/sh
if [ "${MOCK_STTY_MODE:-ok}" = "ok" ]; then
  printf '24 %s\n' "${MOCK_STTY_COLS:-80}"
  exit 0
fi
exit 1
EOF

  cat > "$mock_dir/tmux" <<'EOF'
#!/bin/sh
if [ "${MOCK_TMUX_MODE:-ok}" = "ok" ]; then
  printf '%s\n' "${MOCK_TMUX_WIDTH:-45}"
  exit 0
fi
exit 1
EOF

  cat > "$mock_dir/tput" <<'EOF'
#!/bin/sh
if [ "${MOCK_TPUT_MODE:-ok}" = "ok" ]; then
  printf '%s\n' "${MOCK_TPUT_COLS:-132}"
  exit 0
fi
exit 1
EOF

  cat > "$mock_dir/uname" <<'EOF'
#!/bin/sh
if [ "${MOCK_UNAME_DARWIN:-0}" = "1" ]; then
  printf 'Darwin\n'
else
  command uname "$@"
fi
EOF

  chmod +x "$mock_dir/stty" "$mock_dir/tmux" "$mock_dir/tput" "$mock_dir/uname"
}

# script(1) invocation differs between GNU util-linux (-c <command>) and
# BSD/macOS (command passed as positional args after the typescript file).
# Probe once at startup and reuse so tty-capture cases run on both flavors.
SCRIPT_STYLE=""

detect_script_style() {
  if script -qec "true" /dev/null >/dev/null 2>&1; then
    SCRIPT_STYLE=gnu
  else
    SCRIPT_STYLE=bsd
  fi
}

tty_capture() {
  out_file="$1"
  command_string="$2"
  if [ "$SCRIPT_STYLE" = "gnu" ]; then
    script -qec "$command_string" /dev/null > "$out_file" 2>&1
  else
    script -q /dev/null sh -c "$command_string" > "$out_file" 2>&1
  fi
}

case_smoke() {
  out_file="$1"
  status=0

  (
    DF_PREFIX=fixture
    df_output_init
    df_info "smoke"
  ) > "$out_file" 2>&1

  captured=$(cat "$out_file")
  assert_contains "[dotfiles:fixture]" "$captured" "smoke: prefix" || status=1
  assert_contains "smoke" "$captured" "smoke: message" || status=1
  assert_bytes_clean "$out_file" "smoke: byte-clean" || status=1
  assert_not_contains '\033' "$captured" "smoke: no literal backslash-033" || status=1

  return "$status"
}

case_width_fallback() {
  status=0
  mock_dir="$1/mock-width"
  create_mock_commands "$mock_dir"

  width=$(PATH="$mock_dir:$PATH" MOCK_STTY_MODE=ok MOCK_STTY_COLS=20 DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_width' sh "$LIB")
  assert_eq "20" "$width" "width: stty 20" || status=1

  width=$(PATH="$mock_dir:$PATH" MOCK_STTY_MODE=ok MOCK_STTY_COLS=200 DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_width' sh "$LIB")
  assert_eq "200" "$width" "width: stty 200" || status=1

  width=$(PATH="$mock_dir:$PATH" MOCK_STTY_MODE=fail TMUX=1 MOCK_TMUX_MODE=ok MOCK_TMUX_WIDTH=45 DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_width' sh "$LIB")
  assert_eq "45" "$width" "width: tmux fallback" || status=1

  width=$(PATH="$mock_dir:$PATH" MOCK_STTY_MODE=fail MOCK_TMUX_MODE=fail MOCK_TPUT_MODE=ok MOCK_TPUT_COLS=132 DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_width' sh "$LIB")
  assert_eq "132" "$width" "width: tput fallback" || status=1

  width=$(PATH="$mock_dir:$PATH" MOCK_STTY_MODE=fail MOCK_TMUX_MODE=fail MOCK_TPUT_MODE=fail DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_width' sh "$LIB")
  assert_eq "80" "$width" "width: hard fallback" || status=1

  return "$status"
}

case_truncate_boundary() {
  status=0
  utf_out=$(LC_ALL=en_US.UTF-8 DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_truncate "ᗧ·····" 8' sh "$LIB")
  assert_contains "…" "$utf_out" "truncate: utf8 suffix" || status=1
  utf_len=$(printf '%s' "$utf_out" | wc -c | tr -d ' ')
  if [ "$utf_len" -gt 8 ] 2>/dev/null; then
    printf '[fixture] truncate: utf8 length ... FAIL: got %s bytes (> 8)\n' "$utf_len" >&2
    status=1
  fi

  ascii_out=$(LC_ALL=C DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_truncate "abcdefghi" 6' sh "$LIB")
  assert_contains "..." "$ascii_out" "truncate: ascii suffix" || status=1

  return "$status"
}

case_utf8_detection() {
  status=0
  mock_dir="$1/mock-utf8"
  create_mock_commands "$mock_dir"

  utf8_flag=$(LC_ALL=C DF_PREFIX=fixture sh -c '. "$1"; df_output_init; if df_is_utf8; then printf 1; else printf 0; fi' sh "$LIB")
  assert_eq "0" "$utf8_flag" "utf8: LC_ALL=C" || status=1

  utf8_flag=$(LC_ALL=en_US.UTF-8 DF_PREFIX=fixture sh -c '. "$1"; df_output_init; if df_is_utf8; then printf 1; else printf 0; fi' sh "$LIB")
  assert_eq "1" "$utf8_flag" "utf8: LC_ALL=UTF-8" || status=1

  utf8_flag=$(PATH="$mock_dir:$PATH" MOCK_UNAME_DARWIN=1 LC_ALL= LANG= LC_CTYPE= DF_PREFIX=fixture sh -c '. "$1"; df_output_init; if df_is_utf8; then printf 1; else printf 0; fi' sh "$LIB")
  assert_eq "1" "$utf8_flag" "utf8: darwin unset locale" || status=1

  return "$status"
}

case_byte_clean_modes() {
  status=0
  out_file="$1/byte-clean.out"

  (
    CI=true
    DF_PREFIX=fixture
    df_output_init
    df_step "ci-clean"
    df_step_end 0
  ) > "$out_file" 2>&1

  assert_bytes_clean "$out_file" "byte-clean: CI" || status=1
  ci_out=$(cat "$out_file")
  assert_not_contains "ᗧ" "$ci_out" "byte-clean: no utf8 spinner" || status=1

  (
    unset CI
    DF_PREFIX=fixture
    df_output_init
    df_step "pipe-clean"
    df_step_end 0
  ) | cat > "$out_file"

  assert_bytes_clean "$out_file" "byte-clean: piped" || status=1

  return "$status"
}

case_elapsed_format() {
  status=0

  d=$(DF_PREFIX=fixture sh -c '. "$1"; printf "%s\n" "$(df__fmt_duration 0)"' sh "$LIB")
  assert_eq "00:00" "$d" "elapsed: 0s" || status=1

  d=$(DF_PREFIX=fixture sh -c '. "$1"; printf "%s\n" "$(df__fmt_duration 5)"' sh "$LIB")
  assert_eq "00:05" "$d" "elapsed: 5s" || status=1

  d=$(DF_PREFIX=fixture sh -c '. "$1"; printf "%s\n" "$(df__fmt_duration 65)"' sh "$LIB")
  assert_eq "01:05" "$d" "elapsed: 65s" || status=1

  d=$(DF_PREFIX=fixture sh -c '. "$1"; printf "%s\n" "$(df__fmt_duration 600)"' sh "$LIB")
  assert_eq "10:00" "$d" "elapsed: 600s" || status=1

  d=$(DF_PREFIX=fixture sh -c '. "$1"; printf "%s\n" "$(df__fmt_duration 7200)"' sh "$LIB")
  assert_eq "120:00" "$d" "elapsed: 7200s" || status=1

  d=$(DF_PREFIX=fixture sh -c '. "$1"; printf "%s\n" "$(df__fmt_duration "")"' sh "$LIB")
  assert_eq "00:00" "$d" "elapsed: empty" || status=1

  step_out=$(CI=true DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_step "work"; df_step_end 0' sh "$LIB")
  step_start=$(printf '%s\n' "$step_out" | sed -n '1p')
  step_done=$(printf '%s\n' "$step_out" | sed -n '2p')

  assert_contains "work..." "$step_start" "step-end: start line" || status=1
  assert_contains "(00:00)" "$step_start" "step-end: in-progress MM:SS" || status=1
  assert_contains "work..." "$step_done" "step-end: success line" || status=1
  assert_contains "done" "$step_done" "step-end: done mark" || status=1
  if printf '%s\n' "$step_done" | LC_ALL=C grep -Eq '\([0-9]+:[0-9]{2}\)'; then
    printf '[fixture] step-end: success has no MM:SS ... FAIL: [%s]\n' "$step_done" >&2
    status=1
  fi

  return "$status"
}

case_color_escapes() {
  status=0
  if ! command -v script >/dev/null 2>&1; then
    printf '[fixture] color: script(1) unavailable, skipping\n'
    return 0
  fi

  esc_file="$1/color-esc.out"
  tty_capture "$esc_file" "env DF_PREFIX=fixture CI=false DOTFILES_VERBOSE=0 sh -c '. \"$LIB\"; df_output_init; df_ok colored'"

  assert_has_esc "$esc_file" "color: real ESC bytes emitted" || status=1
  esc_out=$(cat "$esc_file")
  assert_contains "colored" "$esc_out" "color: message present" || status=1
  assert_not_contains '\033' "$esc_out" "color: no literal backslash-033" || status=1

  plain_file="$1/color-plain.out"
  tty_capture "$plain_file" "env DF_PREFIX=fixture CI=false DOTFILES_VERBOSE=0 DOTFILES_NO_COLOR=1 sh -c '. \"$LIB\"; df_output_init; df_ok plain'"

  assert_no_esc "$plain_file" "color: no-color emits no ESC" || status=1

  return "$status"
}

case_step_tty() {
  status=0
  if ! command -v script >/dev/null 2>&1; then
    printf '[fixture] step: script(1) unavailable, skipping\n'
    return 0
  fi

  # No animated spinner frames: step output is static start + completion lines.
  # In-progress line includes MM:SS; success line omits it. Assert the stable,
  # persistable tty output: step name, start/completion lines, absence of frame
  # glyphs, and no
  # literal backslash escape artifacts. Both locale runs are kept to exercise
  # the utf8 and C mark paths.
  utf_file="$1/step-utf.out"
  ascii_file="$1/step-ascii.out"

  tty_capture "$utf_file" "env DF_PREFIX=fixture LC_ALL=en_US.UTF-8 CI=false GITHUB_ACTIONS= DOTFILES_VERBOSE=0 sh -c '. \"$LIB\"; df_output_init; df_step spin; sleep 1.0; df_step_end 0'"
  # On a tty the start frame and its redraws share ONE physical line, separated
  # by CR, so split on CR as well as LF to inspect individual frames.
  utf_out=$(tr '\r' '\n' < "$utf_file")
  utf_start=$(printf '%s\n' "$utf_out" | LC_ALL=C grep -F 'spin...' | sed -n '1p')
  utf_done=$(printf '%s\n' "$utf_out" | LC_ALL=C grep -F 'spin...' | sed -n '$p')
  assert_contains "spin" "$utf_start" "step-utf: step name" || status=1
  assert_contains "spin..." "$utf_start" "step-utf: start line" || status=1
  assert_contains "(00:00)" "$utf_start" "step-utf: in-progress MM:SS" || status=1
  assert_contains "✓" "$utf_done" "step-utf: utf8 done mark" || status=1
  assert_contains "done" "$utf_done" "step-utf: completion line" || status=1
  if printf '%s\n' "$utf_done" | LC_ALL=C grep -Eq '\([0-9]+:[0-9]{2}\)'; then
    printf '[fixture] step-utf: no success MM:SS timer ... FAIL\n' >&2
    status=1
  fi
  assert_not_contains "ᗧ" "$utf_out" "step-utf: no spinner frames" || status=1
  assert_not_contains '\033' "$utf_out" "step-utf: no literal backslash-033" || status=1

  tty_capture "$ascii_file" "env DF_PREFIX=fixture LC_ALL=C CI=false GITHUB_ACTIONS= DOTFILES_VERBOSE=0 sh -c '. \"$LIB\"; df_output_init; df_step spin; sleep 1.0; df_step_end 0'"
  ascii_out=$(tr '\r' '\n' < "$ascii_file")
  ascii_start=$(printf '%s\n' "$ascii_out" | LC_ALL=C grep -F 'spin...' | sed -n '1p')
  ascii_done=$(printf '%s\n' "$ascii_out" | LC_ALL=C grep -F 'spin...' | sed -n '$p')
  assert_contains "spin" "$ascii_start" "step-ascii: step name" || status=1
  assert_contains "spin..." "$ascii_start" "step-ascii: start line" || status=1
  assert_contains "(00:00)" "$ascii_start" "step-ascii: in-progress MM:SS" || status=1
  assert_contains "OK" "$ascii_done" "step-ascii: ascii done mark" || status=1
  assert_contains "done" "$ascii_done" "step-ascii: completion line" || status=1
  if printf '%s\n' "$ascii_done" | LC_ALL=C grep -Eq '\([0-9]+:[0-9]{2}\)'; then
    printf '[fixture] step-ascii: no success MM:SS timer ... FAIL\n' >&2
    status=1
  fi
  assert_not_contains ">" "$ascii_out" "step-ascii: no spinner frames" || status=1
  assert_not_contains '\033' "$ascii_out" "step-ascii: no literal backslash-033" || status=1

  # Regression: the start frame must NOT be terminated by a newline when the
  # ticker will animate, otherwise the timer counts on the line BELOW a frozen
  # "(00:00)" line. Assert the start frame and the done line land on the same
  # physical line (i.e. no LF between them).
  # Locate the physical line holding the step rather than assuming it is line 1:
  # some `script` implementations (arch's util-linux) emit a preamble line first.
  first_physical=$(LC_ALL=C grep -F -m1 'spin...' "$utf_file")
  assert_contains "(00:00)" "$first_physical" "step-utf: start frame on step line" || status=1
  assert_contains "done" "$first_physical" "step-utf: done shares step line (no LF after start)" || status=1

  return "$status"
}

case_df_run_contract() {
  status=0
  logs="$1/logs"
  mkdir -p "$logs"

  out_file="$1/df-run.out"
  DOTFILES_LOG_DIR="$logs" DF_PREFIX=fixture sh -c '. "$1"; df_output_init; if df_run sh -c "echo child-output; exit 7"; then c=0; else c=$?; fi; printf "code=%s\n" "$c"; printf "path=%s\n" "$(df_log_path)"' sh "$LIB" > "$out_file" 2>&1

  out=$(cat "$out_file")
  assert_contains "code=7" "$out" "df_run: exit code" || status=1
  assert_not_contains "child-output" "$out" "df_run: default no stdout leak" || status=1
  log_path=$(printf '%s\n' "$out" | awk -F= '/^path=/{print $2}' | sed -n '1p')

  if [ -z "$log_path" ] || [ ! -f "$log_path" ]; then
    printf '[fixture] df_run: log path ... FAIL: missing file\n' >&2
    status=1
  else
    log_content=$(cat "$log_path")
    assert_contains "child-output" "$log_content" "df_run: child output captured" || status=1
    assert_contains "details: $log_path" "$out" "df_run: failure path surfaced" || status=1
  fi

  if command -v script >/dev/null 2>&1; then
    tty_out="$1/df-run-tty.out"
    tty_capture "$tty_out" "env DOTFILES_LOG_DIR='$logs' DF_PREFIX=fixture sh -c '. \"$LIB\"; df_output_init; df_run sh -c \"echo tty-suppressed\"'"
    tty_content=$(cat "$tty_out")
    assert_not_contains "tty-suppressed" "$tty_content" "df_run: tty default suppresses" || status=1
  fi

  verbose_out="$1/df-run-verbose.out"
  DOTFILES_LOG_DIR="$logs" DOTFILES_VERBOSE=1 DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_run sh -c "echo verbose-stream"' sh "$LIB" > "$verbose_out" 2>&1
  verbose_content=$(cat "$verbose_out")
  assert_contains "verbose-stream" "$verbose_content" "df_run: verbose streams" || status=1

  return "$status"
}

case_step_fail_latch() {
  status=0

  # A df_run failure inside a step must force a failure mark even when the
  # caller swallows the status and passes a hard-coded 0 to df_step_end.
  out_file="$1/latch.out"
  DOTFILES_LOG_DIR="$1/logs" CI=true DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_step "work"; df_run sh -c "exit 100" || true; if df_step_end 0; then printf "rc=0\n"; else printf "rc=%s\n" "$?"; fi' sh "$LIB" > "$out_file" 2>&1

  out=$(cat "$out_file")
  assert_contains "failed" "$out" "latch: failure mark on swallowed df_run" || status=1
  assert_not_contains "done" "$out" "latch: no success mark" || status=1
  assert_contains "rc=100" "$out" "latch: df_step_end returns latched code" || status=1

  # Explicit caller status still wins when nothing latched.
  clean_file="$1/latch-clean.out"
  CI=true DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_step "work"; if df_step_end 0; then printf "rc=0\n"; else printf "rc=%s\n" "$?"; fi' sh "$LIB" > "$clean_file" 2>&1
  clean_out=$(cat "$clean_file")
  assert_contains "done" "$clean_out" "latch: clean step still succeeds" || status=1
  assert_contains "rc=0" "$clean_out" "latch: clean step returns 0" || status=1

  # The latch must not leak into the next step.
  reset_file="$1/latch-reset.out"
  DOTFILES_LOG_DIR="$1/logs" CI=true DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_step "one"; df_run sh -c "exit 3" || true; df_step_end 0 || true; df_step "two"; if df_step_end 0; then printf "rc=0\n"; else printf "rc=%s\n" "$?"; fi' sh "$LIB" > "$reset_file" 2>&1
  reset_out=$(cat "$reset_file")
  assert_contains "rc=0" "$reset_out" "latch: reset by next df_step" || status=1

  # df_run_soft failures are deliberately non-fatal to the step.
  soft_file="$1/latch-soft.out"
  DOTFILES_LOG_DIR="$1/logs" CI=true DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_step "work"; df_run_soft sh -c "exit 4" || true; if df_step_end 0; then printf "rc=0\n"; else printf "rc=%s\n" "$?"; fi' sh "$LIB" > "$soft_file" 2>&1
  soft_out=$(cat "$soft_file")
  assert_contains "rc=0" "$soft_out" "latch: df_run_soft does not latch" || status=1

  return "$status"
}

case_redraw_gating() {
  status=0

  # CI, non-TTY and verbose modes must emit a single static line with no
  # carriage-return redraw bytes.
  ci_file="$1/redraw-ci.out"
  CI=true DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_step "work"; sleep 2; df_step_end 0' sh "$LIB" > "$ci_file" 2>&1
  assert_bytes_clean "$ci_file" "redraw: no CR/ESC in CI" || status=1

  piped_file="$1/redraw-piped.out"
  CI=false DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_step "work"; sleep 2; df_step_end 0' sh "$LIB" > "$piped_file" 2>&1
  assert_bytes_clean "$piped_file" "redraw: no CR/ESC when piped" || status=1

  verbose_file="$1/redraw-verbose.out"
  CI=false DOTFILES_VERBOSE=1 DF_PREFIX=fixture sh -c '. "$1"; df_output_init; df_step "work"; sleep 2; df_step_end 0' sh "$LIB" > "$verbose_file" 2>&1
  assert_bytes_clean "$verbose_file" "redraw: no CR/ESC in verbose" || status=1

  ci_out=$(cat "$ci_file")
  assert_eq "2" "$(printf '%s\n' "$ci_out" | grep -c 'work\.\.\.')" "redraw: exactly start + end lines in CI" || status=1

  if ! command -v script >/dev/null 2>&1; then
    printf '[fixture] redraw: script(1) unavailable, skipping tty ticker\n'
    return "$status"
  fi

  # On a tty the ticker redraws in place. Assert stable observable output only:
  # the timer advances past 00:00, the final line is correct and last, and no
  # ticker output leaks after the step ends. Exact intermediate frames are not
  # asserted because they were flaky in CI.
  tty_file="$1/redraw-tty.out"
  tty_capture "$tty_file" "env DF_PREFIX=fixture LC_ALL=en_US.UTF-8 CI=false GITHUB_ACTIONS= DOTFILES_VERBOSE=0 sh -c '. \"$LIB\"; df_output_init; df_step tick; sleep 3; df_step_end 0; sleep 2; printf \"SENTINEL\\n\"'"
  tty_out=$(cat "$tty_file")

  assert_contains "tick..." "$tty_out" "redraw: step name present" || status=1
  assert_contains "done" "$tty_out" "redraw: completion line present" || status=1
  if ! printf '%s\n' "$tty_out" | LC_ALL=C grep -Eq '\(00:0[1-9]\)'; then
    printf '[fixture] redraw: timer advances past 00:00 ... FAIL\n' >&2
    status=1
  fi

  # Nothing but the sentinel may appear after the completion line: a leaked
  # ticker would inject another "tick... (MM:SS)" there.
  tail_out=$(printf '%s\n' "$tty_out" | sed -n '/done/,$p' | sed -n '2,$p')
  assert_not_contains "tick..." "$tail_out" "redraw: no ticker output after step end" || status=1
  assert_contains "SENTINEL" "$tty_out" "redraw: sentinel reached" || status=1

  return "$status"
}

case_nested_step_tty() {
  status=0

  harness="$REPO_ROOT/scripts/tests/step-harness.sh"
  if [ ! -r "$harness" ]; then
    printf '[fixture] nested: harness not found, skipping\n'
    return 0
  fi

  if ! command -v script >/dev/null 2>&1; then
    printf '[fixture] nested: script(1) unavailable, skipping\n'
    return 0
  fi

  # Regression: a parent step must never run a ticker while a child process
  # prints its own step output to the same terminal. The parent's ticker leaves
  # the cursor mid-line, so the child's first df_info appends to it, producing
  # an over-width line that wraps into permanent garbage and shows a frozen
  # (00:00). Assert no rendered line carries two prefixes.
  out_file="$1/nested.out"
  tty_capture "$out_file" "env GITHUB_ACTIONS= CI=false HARNESS_SLEEP=3 DOTFILES_BIN='$BIN' sh '$harness' outer"

  nested_out=$(cat "$out_file" | tr '\r' '\n')

  dup=$(printf '%s\n' "$nested_out" | LC_ALL=C grep -c '\[dotfiles:.*\[dotfiles:' || true)
  if [ "$dup" -ne 0 ] 2>/dev/null; then
    printf '[fixture] nested: no concatenated prefixes ... FAIL: %s line(s)\n' "$dup" >&2
    status=1
  fi

  assert_contains "Outer wrapping child..." "$nested_out" "nested: outer step present" || status=1
  assert_contains "Inner slow work..." "$nested_out" "nested: inner step present" || status=1
  assert_contains "done" "$nested_out" "nested: completion reached" || status=1

  # The inner (child) step owns the line, so its timer must advance.
  if ! printf '%s\n' "$nested_out" | LC_ALL=C grep -Eq 'Inner slow work\.\.\. \(00:0[1-9]\)'; then
    printf '[fixture] nested: inner timer advances ... FAIL\n' >&2
    status=1
  fi

  # No rendered line may exceed the terminal width: an over-width line is the
  # visible symptom of the concatenation bug.
  width=$(df_width)
  long=$(printf '%s\n' "$nested_out" | LC_ALL=C awk -v w="$width" 'length($0) > w' | wc -l | tr -d ' ')
  if [ "$long" -ne 0 ] 2>/dev/null; then
    printf '[fixture] nested: no over-width lines ... FAIL: %s line(s) exceed %s cols\n' "$long" "$width" >&2
    status=1
  fi

  return "$status"
}

main() {
  temp_dir=$(mktemp -d)
  trap 'rm -rf "$temp_dir"' EXIT

  detect_script_style

  run_case "smoke: source + init + df_info" case_smoke "$temp_dir/smoke.out"
  run_case "df_width: fallback chain" case_width_fallback "$temp_dir"
  run_case "df_truncate: boundary + suffix" case_truncate_boundary
  run_case "df_is_utf8: locale + darwin" case_utf8_detection "$temp_dir"
  run_case "byte-clean: CI + piped" case_byte_clean_modes "$temp_dir"
  run_case "elapsed: MM:SS format" case_elapsed_format
  run_case "color: escape bytes vs literal" case_color_escapes "$temp_dir"
  run_case "step: static tty output (start + done)" case_step_tty "$temp_dir"
  run_case "df_run: exit/log/path/tty" case_df_run_contract "$temp_dir"
  run_case "step: failure latch propagation" case_step_fail_latch "$temp_dir"
  run_case "step: redraw gating + live timer" case_redraw_gating "$temp_dir"
  run_case "step: nested parent/child tty" case_nested_step_tty "$temp_dir"

  if [ "$FIXTURE_FAILED" -eq 1 ]; then
    printf '[fixture] RESULT: FAIL\n' >&2
    exit 1
  fi

  printf '[fixture] RESULT: PASS\n'
  exit 0
}

main
