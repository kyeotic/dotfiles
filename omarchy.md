# Omarchy machine setup

Setup to do on every Omarchy machine that the dotfiles can't (or shouldn't) do on
their own: per-machine files that stay out of the repo, and one-time manual steps.
Run `scripts/init` (or `scripts/install_apps` + `scripts/stow`) first.

## Monitors (`~/.config/hypr/monitors.lua`, machine-local)

`monitors.lua` is deliberately not in the repo. Omarchy installs a default one.

- **Pin the refresh rate.** `mode = "preferred"` can pick 60Hz on high-refresh
  monitors (it did on the ASUS PG27UCDM, which does 240Hz). List the real modes with
  `hyprctl monitors all`, then set the mode explicitly:
  ```lua
  hl.monitor({ output = "DP-3", mode = "3840x2160@240", position = "0x0", scale = 1.5, vrr = 2 })
  ```
- **Turn on VRR** with `vrr = 2` on gaming monitors. It enables adaptive sync for
  fullscreen apps only, which avoids the brightness flicker OLEDs get with VRR
  on the desktop. `hyprctl monitors` reports `vrr=false` until something goes fullscreen.
  Without this, a game's in-game "Adaptive Sync" setting does nothing.
- Apply with `hyprctl reload`, then check `hyprctl configerrors` and
  `hyprctl monitors -j | jq -r '.[] | "\(.name) \(.refreshRate) vrr=\(.vrr)"'`.
- 60Hz-only monitors (e.g. LG UltraFine) cap any game on them at 60. Play on
  the high-refresh monitor.

### HDR

- **Force HDR on HDR monitors** (check with `edid-decode /sys/class/drm/card*-DP-3/edid | grep ST2084`).
  Without `cm = "hdr"` the desktop stays sRGB and only fullscreen apps that ask for HDR
  over Wayland get it (`render:cm_auto_hdr`):
  ```lua
  hl.monitor({ output = "DP-3", mode = "3840x2160@240", position = "0x0", scale = 1.5, vrr = 2,
               bitdepth = 10, cm = "hdr", sdr_max_luminance = 250 })
  ```
  `hyprctl monitors` should show `colorManagementPreset: hdr` and `currentFormat: XBGR2101010`.
- **SDR content is mapped into HDR.** `sdr_max_luminance` is the SDR white level in nits.
  The default of 80 looks dim and washed out on an OLED. Raise it if SDR looks dim; lower it
  if it's too bright. `sdrbrightness` and `sdrsaturation` (typically 1.0–2.0) also tune SDR.
- Skip forced HDR on low-nit panels (the LG UltraFine peaks around 300 nits), where SDR
  only looks worse.
- **XWayland apps can't output HDR.** Native Linux games (e.g. Godot games like Slay the
  Spire 2) run through XWayland and show as SDR.
- **Proton games** need the Wine Wayland driver for HDR. Use the Steam launch option
  `PROTON_ENABLE_WAYLAND=1 PROTON_ENABLE_HDR=1 %command%`, then turn on HDR in the game.
  Not set globally, because the Wayland driver breaks some launchers and overlays.
  If a game shows a white screen or flickers on start, try `quirks:prefer_hdr = 1`.
- 10-bit output: Hyprland border colors stay 8-bit, and some screen-capture tools don't
  support 10-bit.

## Gaming

### Proton games on a multi-monitor setup (XWayland)

By default Proton runs games through XWayland. XWayland keeps its own monitor
layout, which Hyprland builds and which doesn't match Hyprland's:

| | DP-3 (main) | DP-2 (portrait) |
|---|---|---|
| Hyprland (scaled units) | left, 0 → 2560 | right, 2560 → 4000 |
| XWayland (raw pixels) | right, 2160 → 6000 | left, 0 → 2160 |

XWayland seems to order outputs by monitor ID, not by position, and uses pixels
because Omarchy sets `xwayland.force_zero_scaling = true`. There's no setting to
reorder it. Compare with `xrandr --listmonitors` vs `hyprctl monitors`. This causes
two problems:

- **Squished/stretched gameplay, menus fine** (seen with Nova Drift, a GameMaker
  game). XWayland had no primary output and listed the portrait DP-2 first, so the
  game read the portrait size as "the main display" and stretched it onto DP-3.
  - Fix now: `xrandr --output DP-3 --primary`, then fully quit and relaunch the game.
    The primary shows a `*` in `xrandr --listmonitors` (`+*DP-3`).
  - Fix at login: add this to `~/.config/hypr/autostart.lua` (machine-local). It
    retries until XWayland is up:
    ```lua
    hl.on("hyprland.start", function()
      hl.exec_cmd("sh -c 'for i in $(seq 30); do xrandr --output DP-3 --primary 2>/dev/null && exit 0; sleep 1; done'")
    end)
    ```
    It only runs at login. If a monitor reconnects mid-session (e.g. power cycle),
    rerun the `xrandr` command.
- **Mouse stops partway across the game and jumps to the other monitor.** When the
  game confines or warps the cursor, it uses XWayland's coordinates, and Hyprland
  reads them with its own layout. The game's left edge (XWayland x=2160) lands at
  about 2160 / 1.5 = 1440 in Hyprland, past the middle of DP-3, so the usable area
  is shifted right by about half a screen. The primary-monitor fix doesn't help here.

**Fix for both: the Wine Wayland driver.** The Steam launch option
`PROTON_ENABLE_WAYLAND=1 %command%` makes the game a native Wayland client, so
XWayland's layout no longer matters. Needs Proton 10+ (Experimental 11 works);
add `PROTON_ENABLE_HDR=1` for HDR (see HDR above). Fully quit the game before
relaunching. Not set globally, because it breaks some launchers and overlays.
Still being tested with Nova Drift.

### gamescope

The fallback when a game misbehaves on the Wayland driver. gamescope runs the game
inside its own single-screen compositor, so the monitor layout, primary display and
scaling never reach it. Install with `omarchy pkg add gamescope`, then use the Steam
launch option:
```
gamescope -W 3840 -H 2160 -f -- %command%
```
`-W`/`-H` set the output size (DP-3's native resolution) and `-f` starts fullscreen.
Add `-r 240` to cap at the monitor's refresh rate.

### Game stats bar widget (MangoHud)

The bar shows `CPU · GPU · VRAM · FPS` while a game runs. All config is in the
dotfiles (`.config/MangoHud/`, `.config/omarchy/bar/scripts/gamestats`,
`MANGOHUD=1` in `.config/hypr/hyprland.lua`); `install_apps` installs `mangohud`.

**First-time setup on a new machine:**
- **Log out and back in** after the first stow. `MANGOHUD=1` is set by Hyprland,
  and the Omarchy shell (which runs the app launcher) only picks up Hyprland's
  environment at login. Apps launched from a shell that started earlier won't get
  it. To fix it without logging out:
  ```bash
  systemctl --user set-environment MANGOHUD=1
  dbus-update-activation-environment --systemd MANGOHUD=1
  omarchy restart shell
  ```
  Then fully exit Steam (Steam menu → Exit; closing the window isn't enough) and relaunch it.

**Using it:**
- Every Vulkan game (Proton/DXVK and most native games) is picked up
  automatically. **OpenGL-only games** need the Steam launch option `mangohud %command%`.
- The in-game overlay is invisible by default. MangoHud stops logging when its
  HUD is hidden, so preset 1 is a transparent HUD instead. **Shift_R+F10** cycles to
  the full overlay (preset 2).
- If a non-game Vulkan app shows up in the widget, add its process name to
  `blacklist=` in `.config/MangoHud/MangoHud.conf` (mpv is already there).
- Logs go to `/tmp/mangohud/` (MangoHud can't expand `~`). The widget creates the
  folder and deletes logs idle for 30+ minutes.
- **Keep `log_interval=0`.** Any other value makes MangoHud (0.8.4) log from a
  detached thread that is never joined, and it can crash the game during exit
  (segfault in `Logger::try_log` → `~overlay_params`, after the game has already
  saved). `0` logs from the game's render thread instead, about 82 bytes per frame
  (~35-70 MB/hour of `/tmp` at 120-240fps).
- GPU % and VRAM come from `nvidia-smi` when present. On AMD the widget falls
  back to MangoHud's own numbers, where VRAM is per-process.

**Testing without a game:** `sudo pacman -S vulkan-tools`, then
`MANGOHUD=1 vkcube --wsi wayland` and run `~/.config/omarchy/bar/scripts/gamestats`.
It should print JSON while vkcube runs and nothing about 3s after it closes.

## On update

Things to check after updating Omarchy (`omarchy update`). Check the version with
`omarchy version`.

- **Past 4.0.4: remove the VS Code theme reload hook.** Omarchy 4.0.4's generated
  "Omarchy" VS Code theme doesn't reload when the theme changes
  ([#9336](https://github.com/omacom/omarchy/issues/9336)), so
  `config-linux/omarchy/hooks/theme-set.d/vscode-reload-theme` works around it.
  The fix ([PR #10134](https://github.com/omacom/omarchy/pull/10134)) was merged
  after 4.0.4. Once a newer release is installed, delete the hook and its paragraph
  in `AGENTS.md`, then remove the dangling link with
  `rm ~/.config/omarchy/hooks/theme-set.d/vscode-reload-theme`.
  Leaving the hook in place is harmless, but it does nothing useful after the fix.
