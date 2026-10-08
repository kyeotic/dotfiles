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

-- Discord push-to-talk. Wayland has no global key grabs, so forward the keys to the
-- Discord window. Discord must run under XWayland for this, see
-- home/.local/share/applications/discord.desktop.
local discord = "class:^(discord)$"
-- pass forwards press and release. Left Alt still reaches the focused app.
-- ignore_mods: on release Alt is itself a held mod, so without it the release never
-- matches and Discord stays transmitting.
o.bind("ALT_L", "Discord push-to-talk", hl.dsp.pass({ window = discord }), { non_consuming = true, ignore_mods = true })
-- Razer Naga side button (mouse:276). XWayland drops a passed mouse button
-- immediately, so send Discord F13 (keycode 191 = evdev KEY_F13 + 8; XKB names it
-- XF86Tools) with explicit down/up binds. Record it in Discord by pressing the button.
o.bind("mouse:276", "Discord push-to-talk", hl.dsp.send_key_state({ mods = "", key = "code:191", state = "down", window = discord }))
o.bind("mouse:276", "Discord push-to-talk", hl.dsp.send_key_state({ mods = "", key = "code:191", state = "up", window = discord }), { release = true })
