#!/bin/sh
#
# step-harness.sh — drive fake long-running steps against real elapsed time.
#
# The fixture suite runs steps that finish instantly, so it cannot show whether
# the live timer actually advances or whether nested scripts corrupt each
# other's output. This harness runs slow, fake steps so both are observable.
#
# Modes:
#   inner            single process, one slow step (child role)
#   outer            parent step wrapping the inner script (nesting repro)
#   outer-ticker     same, but parent uses the ticker step (the broken shape)
#
# Usage:
#   sh scripts/tests/step-harness.sh outer
#   script -qfc "sh scripts/tests/step-harness.sh outer" /tmp/out.txt

set -eu

HARNESS_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd "$HARNESS_DIR/../.." && pwd)
BIN="${DOTFILES_BIN:-$REPO_ROOT/linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin}"
LIB="$BIN/dotfiles-lib-output"

if [ ! -r "$LIB" ]; then
    printf 'step-harness: library not found at %s\n' "$LIB" >&2
    exit 1
fi

. "$LIB"

HARNESS_SLEEP="${HARNESS_SLEEP:-3}"

run_step() {
    label="$1"
    shift
    df_step "$label"
    if "$@"; then
        code=0
    else
        code=$?
    fi
    df_step_end "$code"
    return "$?"
}

run_child_step() {
    label="$1"
    shift
    df_step_quiet "$label"
    if "$@"; then
        code=0
    else
        code=$?
    fi
    df_step_end "$code"
    return "$?"
}

slow_work() {
    sleep "$HARNESS_SLEEP"
}

mode_inner() {
    DF_PREFIX=harness-inner
    df_output_init
    # Two steps, each longer than the ticker interval. The second step's start
    # line is what a parent ticker would corrupt: by then the parent has ticked
    # and left the cursor mid-line.
    run_step "Inner slow work" slow_work
    run_step "Inner more work" slow_work
}

mode_outer() {
    DF_PREFIX=harness-outer
    df_output_init
    run_child_step "Outer wrapping child" sh "$0" inner
}

mode_outer_ticker() {
    DF_PREFIX=harness-outer
    df_output_init
    run_step "Outer wrapping child" sh "$0" inner
}

case "${1:-inner}" in
    inner)
        mode_inner
        ;;
    outer)
        mode_outer
        ;;
    outer-ticker)
        mode_outer_ticker
        ;;
    *)
        printf 'step-harness: unknown mode: %s\n' "$1" >&2
        exit 2
        ;;
esac
