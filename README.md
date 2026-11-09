# omarchy-dtp-workspace-swipe

A better four finger swipe between workspaces on Omarchy (Hyprland 0.56+).

- The workspace follows your fingers and fades as it goes (Hyprland's `slidefade`).
- The swipe is sized so the commit point, 15% of the screen width of finger travel, falls exactly halfway through it. That is where the workspace is half faded. Half faded means letting go switches; lighter means letting go snaps back.
- Fingers moving left go to the next workspace, right to the previous.

It uses the stock four finger `workspace` gesture from `input.lua`. This only turns the workspace animation back on (Omarchy disables it) and sets `workspace_swipe_distance` and `workspace_swipe_cancel_ratio`. A quick flick can still commit early because of Hyprland's `workspace_swipe_min_speed_to_force`.

Tuning is at the top of `hypr/workspace-swipe.lua`: `COMMIT` and `SENSITIVITY`. Distance is in touchpad delta units against the screen width, so raise `SENSITIVITY` if it takes too much finger travel.

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
