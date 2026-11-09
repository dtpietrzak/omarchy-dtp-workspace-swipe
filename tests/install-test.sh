#!/usr/bin/env bash
# The installer copies the file once, loads it once, and is quiet when run again.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail() {
  echo "not ok - $*" >&2
  exit 1
}

luac -p "$ROOT/hypr/workspace-swipe.lua"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export HOME="$tmpdir"
mkdir -p "$HOME/.config/hypr" "$tmpdir/bin"
cat >"$tmpdir/bin/hyprctl" <<'SH'
#!/bin/sh
printf '%s\n' "$*" >>"$HOME/.hyprctl-log"
exit 0
SH
chmod +x "$tmpdir/bin/hyprctl"
export PATH="$tmpdir/bin:$PATH"

HYPR="$HOME/.config/hypr/hyprland.lua"
printf '%s\n' 'require("hypr.monitors")' 'require("hypr.input")' 'require("hypr.bindings")' >"$HYPR"

"$ROOT/install.sh" >/dev/null
[[ "$(sed -n 3p "$HYPR")" == 'require("hypr.workspace-swipe")' ]] || fail "require not placed after hypr.input"
cmp -s "$ROOT/hypr/workspace-swipe.lua" "$HOME/.config/hypr/workspace-swipe.lua" || fail "file not copied"
grep -qx reload "$HOME/.hyprctl-log" || fail "no reload"

rm -f "$HOME/.hyprctl-log"
before="$(cat "$HYPR")"
"$ROOT/install.sh" >/dev/null
[[ "$(cat "$HYPR")" == "$before" ]] || fail "second run rewrote hyprland.lua"
[[ ! -f $HOME/.hyprctl-log ]] || fail "second run reloaded Hyprland"

# No hypr.input line: appended at the end.
printf '%s\n' '-- bare' >"$HYPR"
"$ROOT/install.sh" >/dev/null
[[ "$(grep -c 'hypr.workspace-swipe' "$HYPR")" == 1 ]] || fail "append failed"

echo "ok"
