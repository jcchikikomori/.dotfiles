#!/bin/sh

set -eu

FIXTURE_FAILED=0

BIN="${DOTFILES_BIN:-}"
if [ -z "$BIN" ]; then
  fixture_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
  repo_root=$(CDPATH= cd "$fixture_dir/../.." && pwd)
  BIN="$repo_root/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin"
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

case_spinner_frames() {
  status=0
  if ! command -v script >/dev/null 2>&1; then
    printf '[fixture] spinner: script(1) unavailable, skipping\n'
    return 0
  fi

  utf_file="$1/spinner-utf.out"
  ascii_file="$1/spinner-ascii.out"

  script -qec "env DF_PREFIX=fixture LC_ALL=en_US.UTF-8 CI=false DOTFILES_VERBOSE=0 sh -c '. \"$LIB\"; df_output_init; df_step spin; sleep 0.4; df_step_end 0'" /dev/null > "$utf_file" 2>&1
  utf_out=$(cat "$utf_file")
  assert_contains "ᗧ" "$utf_out" "spinner: utf8 frame" || status=1

  script -qec "env DF_PREFIX=fixture LC_ALL=C CI=false DOTFILES_VERBOSE=0 sh -c '. \"$LIB\"; df_output_init; df_step spin; sleep 0.4; df_step_end 0'" /dev/null > "$ascii_file" 2>&1
  ascii_out=$(cat "$ascii_file")
  assert_contains ">" "$ascii_out" "spinner: ascii frame" || status=1

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
    script -qec "env DOTFILES_LOG_DIR='$logs' DF_PREFIX=fixture sh -c '. \"$LIB\"; df_output_init; df_run sh -c \"echo tty-auto-stream\"'" /dev/null > "$tty_out" 2>&1
    tty_content=$(cat "$tty_out")
    assert_contains "tty-auto-stream" "$tty_content" "df_run: stdin tty auto-stream" || status=1
  fi

  return "$status"
}

main() {
  temp_dir=$(mktemp -d)
  trap 'rm -rf "$temp_dir"' EXIT

  run_case "smoke: source + init + df_info" case_smoke "$temp_dir/smoke.out"
  run_case "df_width: fallback chain" case_width_fallback "$temp_dir"
  run_case "df_truncate: boundary + suffix" case_truncate_boundary
  run_case "df_is_utf8: locale + darwin" case_utf8_detection "$temp_dir"
  run_case "byte-clean: CI + piped" case_byte_clean_modes "$temp_dir"
  run_case "spinner: frame assertions" case_spinner_frames "$temp_dir"
  run_case "df_run: exit/log/path/tty" case_df_run_contract "$temp_dir"

  if [ "$FIXTURE_FAILED" -eq 1 ]; then
    printf '[fixture] RESULT: FAIL\n' >&2
    exit 1
  fi

  printf '[fixture] RESULT: PASS\n'
  exit 0
}

main
