#!/usr/bin/env bash
# Install the four finger workspace swipe. Copies hypr/workspace-swipe.lua to
# ~/.config/hypr/ and loads it from hyprland.lua after hypr.input, so it can
# replace the stock workspace gesture set there. Safe to run again.
#
#   ./install.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$ROOT/hypr/workspace-swipe.lua"
HYPR_DIR="$HOME/.config/hypr"
TARGET="$HYPR_DIR/workspace-swipe.lua"
HYPRLAND="$HYPR_DIR/hyprland.lua"
REQUIRE='require("hypr.workspace-swipe")'

fail() {
  echo "install: $*" >&2
  exit 1
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  echo "Usage: install.sh"
  echo "Installs the four finger workspace swipe into ~/.config/hypr."
  exit 0
fi
[[ $# -eq 0 ]] || fail "unknown argument: $1"
[[ -f $SOURCE ]] || fail "missing $SOURCE"
[[ -f $HYPRLAND ]] || fail "$HYPRLAND must already exist"

changed=0

if [[ -f $TARGET ]] && cmp -s "$SOURCE" "$TARGET"; then
  echo "workspace-swipe.lua is already installed"
else
  cp "$SOURCE" "$TARGET"
  echo "Installed $TARGET"
  changed=1
fi

if grep -qxF "$REQUIRE" "$HYPRLAND"; then
  echo "hyprland.lua already loads workspace-swipe"
else
  python3 - "$HYPRLAND" "$REQUIRE" <<'PY'
import sys
from pathlib import Path

path, require = Path(sys.argv[1]), sys.argv[2]
lines = path.read_text().splitlines(keepends=True)
anchor = 'require("hypr.input")'
for i, line in enumerate(lines):
    if line.strip() == anchor:
        lines.insert(i + 1, require + "\n")
        break
else:
    if lines and not lines[-1].endswith("\n"):
        lines[-1] += "\n"
    lines.append("\n-- Four finger workspace swipe (omarchy-dtp-workspace-swipe).\n")
    lines.append(require + "\n")
path.write_text("".join(lines))
PY
  echo "Updated hyprland.lua"
  changed=1
fi

if [[ $changed -eq 1 ]]; then
  hyprctl reload >/dev/null
  errors="$(hyprctl configerrors 2>&1 || true)"
  if [[ -n ${errors//[[:space:]]/} ]]; then
    printf '%s\n' "$errors" >&2
    fail "Hyprland reported config errors"
  fi
  echo "Hyprland config reloaded with no errors"
fi
