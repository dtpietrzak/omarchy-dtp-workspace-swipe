# omarchy-dtp-workspace-swipe

A better four finger swipe between workspaces on Omarchy (Hyprland 0.56+).

- The workspace follows your fingers (Hyprland's live swipe) and commits once it has slid 15% of the screen width. Let go sooner and it snaps back. Stock Hyprland needs 50%.
- Fingers moving left go to the next workspace, right to the previous.
- There is no fade: Hyprland's live swipe only moves the workspace, and a Lua gesture that could fade can't share the four finger swipe with it.

It uses the stock four finger `workspace` gesture from `input.lua`. This only turns the workspace animation back on (Omarchy disables it) and sets `workspace_swipe_cancel_ratio`. A quick flick can still commit early because of Hyprland's `workspace_swipe_min_speed_to_force`.

Tuning is `COMMIT` at the top of `hypr/workspace-swipe.lua`. Finger travel per screen is Hyprland's `workspace_swipe_distance`.

## Install

`omarchy-dtp-install` runs this script with the other features. From a local checkout:

```bash
./install.sh
```

It copies `hypr/workspace-swipe.lua` to `~/.config/hypr/` and adds `require("hypr.workspace-swipe")` after `require("hypr.input")` in `hyprland.lua`. Running it again leaves matching files alone.

## Check

```bash
bash tests/install-test.sh
```
