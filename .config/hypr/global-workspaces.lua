-- Global workspaces, as before Omarchy 4.5.
--
-- 4.5 gives every monitor its own workspaces 1-10 (default/hypr/monitor-workspaces.lua),
-- so Super+N acts on the focused monitor and reaching another monitor's workspace
-- means focusing that monitor first. This puts back one shared set, 1-10: Super+N
-- shows workspace N wherever it is, and a new one opens on the focused monitor unless
-- a workspace rule in monitors.lua pins it.
--
-- Omarchy has no setting for this, so it replaces the module's functions and rebinds
-- the keys the module bound. Recheck it after an Omarchy update (omarchy.md, On update).

-- Before 4.5 there's no module, and workspaces are already global.
if not o.workspaces then
  return
end

local paths = require("default.hypr.paths")

-- Renumbers workspaces into per-monitor blocks at startup, on reload and on hotplug.
-- The module's event handlers look it up on this table, so this turns them off.
o.workspaces.reconcile = function() end

-- The bar's workspace buttons run `o.workspaces.focus(slot, monitor)` through
-- `hyprctl dispatch`; slot is the workspace number while every bar is on block 0.
o.workspaces.focus = function(slot)
  return hl.dsp.focus({ workspace = tostring(slot) })
end

o.workspaces.move_window = function(slot, follow)
  return hl.dsp.window.move({ workspace = tostring(slot), follow = follow ~= false })
end

o.workspaces.move_to_monitor = function(direction)
  return hl.dsp.workspace.move({ monitor = direction })
end

-- The bar reads each monitor's block from this file. Without it every bar falls back
-- to block 0 and lists workspaces 1-5 and any others up to 10, as the 4.0 bar did.
-- Only the functions replaced above write it.
os.remove(paths.state_home .. "/omarchy/monitor-workspaces")

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  o.rebind("SUPER + " .. key, "Switch to workspace " .. workspace, o.workspaces.focus(workspace))
  o.rebind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, o.workspaces.move_window(workspace))
  o.rebind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. workspace, o.workspaces.move_window(workspace, false))
end

o.rebind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.rebind("SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.rebind("SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
o.rebind("SUPER + mouse_down", "Scroll active workspace forward", hl.dsp.focus({ workspace = "e+1" }))
o.rebind("SUPER + mouse_up", "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }))

for key, direction in pairs({ LEFT = "l", RIGHT = "r", UP = "u", DOWN = "d" }) do
  o.rebind("SUPER + SHIFT + ALT + " .. key, "Move workspace to " .. key:lower() .. " monitor", o.workspaces.move_to_monitor(direction))
end
