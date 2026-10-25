-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Scrolling screenshot: select a region, then scroll it. Needs wayscrollshot (AUR
-- wayscrollshot-bin), which has no launcher entry. Saves to ~/Pictures/wayscrollshot.
-- The PATH prefix swaps in a grim wrapper (.config/wayscrollshot/grim) so shots
-- aren't captured at 1x and blurry on scaled monitors.
o.bind("CTRL + SHIFT + PRINT", "Scrolling screenshot", "pkill wayscrollshot || PATH=$HOME/.config/wayscrollshot:$PATH wayscrollshot")

-- Same command as the Omarchy menu's Suspend entry.
o.bind("CTRL + SUPER + F12", "Suspend", "systemctl suspend")

-- Discord push-to-talk via the GlobalShortcuts portal. Discord registers
-- discord:discord-push-to-talk once a PTT keybind exists in its settings (check with
-- `hyprctl globalshortcuts`). Forwarding keys to the XWayland Discord window with
-- pass/send_key_state broke in fullscreen Proton games: the game grabs the X keyboard,
-- so XWayland handed the keys to it instead of Discord. global goes over D-Bus and
-- sends both press and release.
local discord_ptt = "discord:discord-push-to-talk"
-- Left Alt still reaches the focused app. ignore_mods: on release Alt is itself a
-- held mod, so without it the release never matches and Discord stays transmitting.
o.bind("ALT_L", "Discord push-to-talk", hl.dsp.global(discord_ptt), { non_consuming = true, ignore_mods = true })
-- Razer Naga side button. Also the Steam Controller back button: steam-ptt.service
-- (config-linux/steam-ptt) reads it from the controller's raw HID reports and presses
-- this button on a virtual mouse, since Steam Input's key output never reaches Hyprland.
o.bind("mouse:276", "Discord push-to-talk", hl.dsp.global(discord_ptt))
