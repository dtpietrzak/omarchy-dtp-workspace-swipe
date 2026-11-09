-- Four finger swipe between workspaces, with a fade.
--
-- The current workspace fades from 100% to 75% over the first 15% of the
-- screen width, drops to 50% at 15%, and the swipe commits to the next or
-- previous workspace when it is let go at 15% or more. Letting go sooner puts
-- the workspace back.
--
-- This replaces the stock `workspace` gesture, which cannot report progress.

local FINGERS = 4
local COMMIT = 0.15 -- share of the screen width that commits the swipe
local FADE_TO = 0.75 -- opacity reached just before COMMIT
local COMMITTED = 0.5 -- opacity once COMMIT is reached
-- Touchpad delta units per pixel of screen width. Raise it for a swipe that
-- needs less finger travel.
local SENSITIVITY = 1.0

-- Drop the stock four finger workspace gesture so this one is not shadowed.
hl.gesture({ fingers = FINGERS, direction = "horizontal", action = "unset" })

local state = nil

local function screen_width(monitor)
  if not monitor then
    return 1920
  end
  local scale = monitor.scale
  if not scale or scale == 0 then
    scale = 1
  end
  local width, height = monitor.width, monitor.height
  if (monitor.transform or 0) % 2 == 1 then
    width = height
  end
  return width / scale
end

local function opacity_for(progress)
  if progress >= COMMIT then
    return COMMITTED
  end
  return 1 - (1 - FADE_TO) * (progress / COMMIT)
end

-- Hyprland runs these callbacks itself, so calling hyprctl from one would wait
-- on Hyprland forever. The fade therefore only sets a value and restores it to 1.
local function track(windows)
  local entries = {}
  for _, window in ipairs(windows) do
    entries[#entries + 1] = { window = window }
  end
  return entries
end

local function set_opacity(window, prop, value)
  hl.dispatch(hl.dsp.window.set_prop({ window = window, prop = prop, value = tostring(value) }))
end

local function apply(factor)
  for _, entry in ipairs(state.windows) do
    set_opacity(entry.window, "opacity", factor)
    set_opacity(entry.window, "opacity_inactive", factor)
  end
end

local function restore()
  for _, entry in ipairs(state.windows) do
    set_opacity(entry.window, "opacity", 1)
    set_opacity(entry.window, "opacity_inactive", 1)
  end
end

local function begin(event)
  local monitor = hl.get_active_monitor()
  local workspace = hl.get_active_workspace()
  local windows = {}
  if workspace then
    windows = hl.get_workspace_windows(workspace) or {}
  end
  state = {
    width = screen_width(monitor),
    travel = 0,
    factor = 1,
    windows = track(windows),
  }
  state.travel = event.delta.x * SENSITIVITY
end

local function update(event)
  if not state then
    return
  end
  state.travel = state.travel + event.delta.x * SENSITIVITY
  local factor = opacity_for(math.abs(state.travel) / state.width)
  if math.abs(factor - state.factor) >= 0.005 then
    state.factor = factor
    apply(factor)
  end
end

local function finish(event)
  if not state then
    return
  end
  local committed = not event.cancelled and math.abs(state.travel) / state.width >= COMMIT
  local forward = state.travel < 0 -- fingers moving left reveal the next workspace
  restore()
  state = nil
  if committed then
    hl.dispatch(hl.dsp.focus({ workspace = forward and "m+1" or "m-1" }))
  end
end

hl.gesture({
  fingers = FINGERS,
  direction = "horizontal",
  action = { start = begin, update = update, finish = finish },
})

-- Omarchy turns the workspace animation off. Turn it back on so the switch
-- slides once the swipe is let go.
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slide" })
