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

## Game stats bar widget (MangoHud)

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
