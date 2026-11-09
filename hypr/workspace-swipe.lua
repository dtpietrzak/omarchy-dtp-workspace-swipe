-- Four finger swipe between workspaces, using Hyprland's own live swipe.
--
-- The workspace follows your fingers and the swipe commits once it has slid
-- COMMIT of the screen width. Let go sooner and it snaps back.
--
-- Hyprland's live swipe only moves the workspace. It never changes opacity, so
-- there is no fade here. (A Lua gesture could fade, but it can't share the
-- four finger swipe with the built-in one, so it would lose the live slide.)

local COMMIT = 0.15 -- share of the screen width the workspace must slide to commit

hl.config({
  gestures = {
    workspace_swipe_cancel_ratio = COMMIT,
  },
})

-- Omarchy turns the workspace animation off. The swipe needs it to show anything.
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slide" })
