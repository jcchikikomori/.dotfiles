#!/bin/sh
#
# assert-output-contract.sh <capture-file> <label>
#
# Assert that a captured default-mode run emitted ONLY prefixed step lines.
#
# Every line a migrated script writes to the terminal must look like
# "[dotfiles:<script>] ...". An unprefixed line means child output escaped
# df_run and painted over the loading screen (see #260). Blank lines are
# tolerated; anything else is a leak.
#
# Kept as a standalone script so the Docker smoke test and the CI workflow
# assert the same contract with one implementation.

set -eu

FILE="${1:?usage: assert-output-contract.sh <capture-file> <label>}"
LABEL="${2:-output}"

if [ ! -f "$FILE" ]; then
  echo "ERROR: $LABEL: capture file not found: $FILE" >&2
  exit 1
fi

# A run that produced nothing at all would otherwise pass vacuously.
if ! grep -q '^\[dotfiles:' "$FILE"; then
  echo "ERROR: $LABEL: no prefixed step output found at all" >&2
  exit 1
fi

UNPREFIXED=$(grep -vE '^[[:space:]]*$' "$FILE" | grep -vE '^\[dotfiles:[a-z0-9-]+\]' || true)
if [ -n "$UNPREFIXED" ]; then
  COUNT=$(printf '%s\n' "$UNPREFIXED" | wc -l | tr -d ' ')
  echo "ERROR: $LABEL: $COUNT unprefixed line(s) leaked in default mode:" >&2
  printf '%s\n' "$UNPREFIXED" >&2
  echo "ERROR: $LABEL: wrap the offending command in df_run (see #260)." >&2
  exit 1
fi

echo "$LABEL: output contract passed (prefixed lines only)."
