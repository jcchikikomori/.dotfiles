#!/bin/sh
set -eu

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y git make stow ca-certificates curl gnupg

HOME_DIR=${HOME:-/root}
mkdir -p "$HOME_DIR/.dotfiles"

# Mirror CI behavior by running from the canonical dotfiles location.
cp -a /workspace/. "$HOME_DIR/.dotfiles/"
cd "$HOME_DIR/.dotfiles"

mkdir -p "$HOME_DIR/.local/state/dotstow"
ln -snf "$HOME_DIR/.dotfiles" "$HOME_DIR/.local/state/dotstow/dotfiles"

# Ensure dotstow is installed before stow workflows run.
sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-dotstow

# Simulate GHCup CI runner behavior: ~/.ghcup is an absolute symlink -> /usr/local/.ghcup.
# This causes "BUG in find_stowed_path" in stow when not excluded. We verify stowme.sh
# handles it correctly by removing and restoring the symlink transparently.
mkdir -p /usr/local/.ghcup
ln -snf /usr/local/.ghcup "$HOME_DIR/.ghcup"
echo "Simulated ~/.ghcup -> /usr/local/.ghcup symlink created."

# Exercise the same path used in CI workflows in non-interactive mode.
yes y | sh debian/stowme.sh

# Verify the symlink was correctly restored after stowing.
if [ -L "$HOME_DIR/.ghcup" ] && [ "$(readlink "$HOME_DIR/.ghcup")" = "/usr/local/.ghcup" ]; then
  echo "~/.ghcup correctly restored after stowing."
else
  echo "ERROR: ~/.ghcup symlink was not restored after stowing!" >&2
  exit 1
fi

# Copyparty non-systemd fallback lifecycle (issue #212 regression).
# This container has no systemd user bus, so dotfiles-copyparty must fall back
# to background-process mode. A stub binary stands in for a pipx-installed
# copyparty to keep the smoke test offline and deterministic.
mkdir -p "$HOME_DIR/.local/bin"
cat >"$HOME_DIR/.local/bin/copyparty" <<'EOF'
#!/bin/sh
echo "copyparty stub args: $*"
while :; do sleep 5; done
EOF
chmod +x "$HOME_DIR/.local/bin/copyparty"

CP="sh linux/systems/.local/bin/org.jcchikikomori.dotfiles/bin/dotfiles-copyparty"
CP_PID_FILE="$HOME_DIR/.local/state/copyparty/copyparty.pid"
CP_LOG_FILE="$HOME_DIR/.local/state/copyparty/copyparty.log"

$CP start
[ -f "$CP_PID_FILE" ]
CP_PID=$(cat "$CP_PID_FILE")
kill -0 "$CP_PID"
$CP status
$CP logs
grep -q "copyparty stub args" "$CP_LOG_FILE"
$CP set-port 3924
[ -f "$CP_PID_FILE" ]
kill -0 "$(cat "$CP_PID_FILE")"
$CP stop
if [ -e "$CP_PID_FILE" ]; then
  echo "ERROR: copyparty PID file still present after stop" >&2
  exit 1
fi
if kill -0 "$CP_PID" 2>/dev/null; then
  echo "ERROR: copyparty process still alive after stop" >&2
  exit 1
fi
$CP startup
grep -q "# BEGIN dotfiles-copyparty autostart" "$HOME_DIR/.profile.local"
$CP stop
if grep -q "# BEGIN dotfiles-copyparty autostart" "$HOME_DIR/.profile.local" 2>/dev/null; then
  echo "ERROR: copyparty autostart block still present after stop" >&2
  exit 1
fi
echo "Copyparty fallback smoke test passed."

echo "Debian compose smoke test passed."
