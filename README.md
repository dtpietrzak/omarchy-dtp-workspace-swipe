# omarchy-dtp-workspace-swipe

A better four finger swipe between workspaces on Omarchy (Hyprland 0.56+).

- The current workspace fades from 100% to 75% over the first 15% of the screen width, then drops to 50% at 15%.
- Letting go at 15% or more switches to the next or previous workspace. Letting go sooner puts the workspace back. Stock Hyprland needs about half of its swipe distance.
- Fingers moving left go to the next workspace, right to the previous, the same as `SUPER + TAB` direction.

The stock `workspace` gesture cannot report progress, so this replaces it with a live Lua gesture. It unsets the stock four finger gesture from `input.lua` first.

Tuning lives at the top of `hypr/workspace-swipe.lua`: `COMMIT`, `FADE_TO`, `COMMITTED` and `SENSITIVITY`. Swipe distance is measured in touchpad delta units against the screen width, so raise `SENSITIVITY` if 15% takes too much finger travel.

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
