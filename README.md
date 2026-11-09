# omarchy-dtp-workspace-swipe

A four finger swipe between workspaces on Omarchy (Hyprland 0.56+), with a fade.

- The current workspace fades from 100% to 95% over the first 7.5% of the screen width, then drops to 50% at 7.5%.
- Letting go at 7.5% or more switches to the next (fingers left) or previous (fingers right) workspace, sliding there. Letting go sooner puts the workspace back.
- It does not wrap. Swiping forward past your last workspace opens the next empty one (unless the current one is already empty). Swiping back from the first one stays put.
- The workspace does not follow your fingers. Hyprland's built-in live swipe can't fade and a Lua gesture can't share the four finger swipe with it, so this uses a Lua gesture and unsets the stock one from `input.lua`.

Windows go back to 100% opacity when you let go. Windows Omarchy makes slightly transparent come back at 100% until their rules refresh. The gesture callbacks must never call `hyprctl`: Hyprland runs them itself and the call would wait on Hyprland forever.

Tuning is at the top of `hypr/workspace-swipe.lua`: `COMMIT`, `FADE_TO`, `COMMITTED` and `SENSITIVITY` (touchpad delta units per pixel of screen width; raise it if 7.5% takes too much finger travel).

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
