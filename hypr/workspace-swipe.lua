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

-- Read each window's own opacity so the fade can be undone exactly. One
-- hyprctl call for the whole workspace.
local function read_originals(windows)
  local originals = {}
  local props = { "opacity", "opacity_inactive", "opacity_override", "opacity_inactive_override" }
  local batch = {}
  for _, window in ipairs(windows) do
    for _, prop in ipairs(props) do
      batch[#batch + 1] = string.format("getprop address:%s %s", window.address, prop)
    end
    originals[#originals + 1] = { window = window, opacity = 1, inactive = 1, override = false, inactive_override = false }
  end
  if #batch == 0 then
    return originals
  end

  local ok, lines = pcall(function()
    local pipe = assert(io.popen("hyprctl --batch '" .. table.concat(batch, " ; ") .. "' 2>/dev/null"))
    local out = {}
    for line in pipe:lines() do
      -- hyprctl separates batched replies with blank lines.
      if line:match("%S") then
        out[#out + 1] = line:match("^%s*(.-)%s*$")
      end
    end
    pipe:close()
    return out
  end)
  if ok and #lines >= #batch then
    for i, entry in ipairs(originals) do
      local base = (i - 1) * #props
      entry.opacity = tonumber(lines[base + 1]) or 1
      entry.inactive = tonumber(lines[base + 2]) or 1
      entry.override = lines[base + 3] == "true"
      entry.inactive_override = lines[base + 4] == "true"
    end
  end
  return originals
end

local function set_opacity(window, prop, value)
  hl.dispatch(hl.dsp.window.set_prop({ window = window, prop = prop, value = tostring(value) }))
end

local function apply(factor)
  for _, entry in ipairs(state.windows) do
    set_opacity(entry.window, "opacity", entry.opacity * factor)
    set_opacity(entry.window, "opacity_inactive", entry.inactive * factor)
  end
end

local function restore()
  for _, entry in ipairs(state.windows) do
    set_opacity(entry.window, "opacity", entry.opacity)
    set_opacity(entry.window, "opacity_inactive", entry.inactive)
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
    windows = read_originals(windows),
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
