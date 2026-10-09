-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- MangoHud on every Vulkan app (feeds the bar gamestats widget); see MangoHud/MangoHud.conf
hl.env("MANGOHUD", "1")

-- Firefox inhibits idle during video through the desktop portal, which Hyprland routes to
-- the GTK backend, where it does nothing. Make it use a Wayland idle inhibitor instead,
-- which the Omarchy idle service respects. Takes effect after restarting Firefox.
hl.env("MOZ_WAKE_LOCK_TYPE", "WaylandIdleInhibit")

-- Tile the main Steam window instead of Omarchy's floating 1100x700. A maximized
-- float loses its maximize when a game goes fullscreen and snaps back small.
o.window({ class = "steam", title = "Steam" }, { tile = true })

-- Make VS Code fully opaque; Omarchy's default (0.985 active / 0.96 inactive) lets the
-- wallpaper show through. Use e.g. "0.97 0.93" for a hint of transparency instead.
o.window("com.microsoft.VSCode", { tag = "-default-opacity", opacity = "0.999 0.985" })

-- Make Firefox fully opaque even when unfocused; Omarchy's default is "1.0 0.985".
o.window({ tag = "firefox-based-browser" }, { opacity = "1 1" })

-- Keep the screensaver off while a fullscreen Steam game is up. Omarchy only covers
-- the "steam" client class; games are steam_app_<id>, and gamepad input doesn't reset idle.
o.window({ class = "^steam_app_\\d+$" }, { idle_inhibit = "fullscreen" })

-- Only show the screensaver on the main monitor (the one at 0,0); the others are switched
-- off (DPMS) until it closes. Omarchy opens one per monitor and has no setting for it.
-- The other copies are kept rather than closed: closing one makes omarchy-screensaver kill
-- all of them and cancel the idle cycle. They're also made invisible, in case a display
-- wakes while the screensaver is still up. The window is fullscreen, so it's drawn with
-- opacity_fullscreen, not opacity. mouse_move_enables_dpms is off while they're blanked:
-- the launcher moving the cursor to the next monitor would otherwise wake them right away.
local screensaver_blanked = {}
local screensaver_mouse_wakes = nil

hl.on("window.open", function(w)
  local m = w.monitor
  if w.class == "org.omarchy.screensaver" and m and (m.x ~= 0 or m.y ~= 0) then
    for _, prop in ipairs({ "opacity", "opacity_fullscreen" }) do
      hl.dispatch(hl.dsp.window.set_prop({ prop = prop, value = "0", window = "address:" .. w.address }))
    end
    if screensaver_mouse_wakes == nil then
      screensaver_mouse_wakes = hl.get_config("misc.mouse_move_enables_dpms")
      hl.config({ misc = { mouse_move_enables_dpms = false } })
    end
    local name = m.name
    screensaver_blanked[name] = true
    hl.timer(function()
      if screensaver_blanked[name] then
        hl.dispatch(hl.dsp.dpms({ action = "disable", monitor = name }))
      end
    end, { timeout = 500, type = "oneshot" })
  end
end)

hl.on("window.close", function(w)
  if w.class ~= "org.omarchy.screensaver" then return end
  if screensaver_mouse_wakes ~= nil then
    hl.config({ misc = { mouse_move_enables_dpms = screensaver_mouse_wakes } })
    screensaver_mouse_wakes = nil
  end
  for name in pairs(screensaver_blanked) do
    hl.dispatch(hl.dsp.dpms({ action = "enable", monitor = name }))
  end
  screensaver_blanked = {}
end)
