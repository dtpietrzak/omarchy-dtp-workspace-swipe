-- Four finger swipe between workspaces, using Hyprland's own live swipe.
--
-- The workspace follows your fingers and fades as it goes (slidefade). The swipe
-- is sized so the commit point sits exactly halfway through it, which is where
-- the workspace is half faded. So half faded means "let go and it switches",
-- and anything lighter means "let go and it snaps back".
--
-- The commit point is COMMIT of the screen width of finger travel.

local COMMIT = 0.15 -- share of the screen width that commits the swipe
local SENSITIVITY = 1.0 -- touchpad delta units per pixel; raise if it takes too much travel

-- The commit is reached at half of the swipe, so the whole swipe is twice that.
local function apply()
  local monitor = hl.get_active_monitor()
  local width = 1920
  if monitor then
    local scale = (monitor.scale and monitor.scale > 0) and monitor.scale or 1
    width = monitor.width / scale
    if (monitor.transform or 0) % 2 == 1 then
      width = monitor.height / scale
    end
  end

  hl.config({
    gestures = {
      workspace_swipe_distance = math.floor(2 * COMMIT * width / SENSITIVITY),
      workspace_swipe_cancel_ratio = 0.5,
    },
  })
end

-- Omarchy turns the workspace animation off. The swipe needs it to show anything.
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slidefade 100%" })

apply()
hl.on("monitor.added", apply)
hl.on("monitor.removed", apply)
hl.on("monitor.layout_changed", apply)
