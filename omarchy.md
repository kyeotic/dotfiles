# Omarchy

Everything in these dotfiles that only applies to Omarchy machines. Not every machine
runs Omarchy, so `AGENTS.md` stays platform-general and points here.

"Config in the repo" covers the Omarchy files the dotfiles stow. The rest is setup to
do on every Omarchy machine that the dotfiles can't (or shouldn't) do on their own:
per-machine files that stay out of the repo, and one-time manual steps. Run
`scripts/init` (or `scripts/install_apps` + `scripts/stow`) first.

## Config in the repo

`omarchy refresh` replaces the stowed symlinks with real files. Copy any changes back
into the repo, then re-run `scripts/stow`.

### `.config/` (stowed on every machine, used only on Omarchy)

- **`hypr/*.lua`**: Hyprland user overrides. `monitors.lua` and `autostart.lua` are
  deliberately NOT in the repo, since monitor/workspace layout and startup apps are
  per-machine. They stay local files in `~/.config/hypr` (see Monitors below).
  - `hyprland.lua` sets `MANGOHUD=1` for all Vulkan apps (see Game stats bar widget).
  - `hyprland.lua` has `window.open`/`window.close` hooks so the Omarchy screensaver only
    shows on the monitor at 0,0. The others are switched off (DPMS, with
    `mouse_move_enables_dpms` turned off while they're blanked) and their screensaver copy
    is made invisible. The copy isn't closed, because closing one makes
    `omarchy-screensaver` kill all of them.
  - `hyprland.lua` sets `MOZ_WAKE_LOCK_TYPE=WaylandIdleInhibit` so Firefox video playback
    blocks the screensaver. By default Firefox uses the desktop portal, whose GTK backend
    does nothing on Hyprland.
  - `bindings.lua` binds Ctrl+Shift+Print to `wayscrollshot` (scrolling screenshots,
    which Omarchy's screenshot tool can't do). Install it per machine with
    `yay -S wayscrollshot-bin`; it ships no launcher entry. wayscrollshot runs
    `grim -s 1`, which captures at logical size (blurry at scale 1.5), so the binding
    puts `.config/wayscrollshot/grim` first on PATH, a wrapper that drops `-s`.
  - `bindings.lua` binds Discord push-to-talk (Left Alt and the Naga side button
    `mouse:276`) to the portal global shortcut `discord:discord-push-to-talk`. Discord
    only registers it while a PTT keybind exists in its settings (check with
    `hyprctl globalshortcuts`). Forwarding keys with `pass`/`send_key_state` failed in
    fullscreen Proton games, which grab the X keyboard.
- **`omarchy/shell.json`**: bar and idle settings.
- **`omarchy/bar/scripts/gamestats`** and **`MangoHud/MangoHud.conf`**: the game stats
  bar widget (see Game stats bar widget below).
- **`voxtype/`**: dictation. `paste-hook` pastes output per window type (and adds a
  leading space when the previous dictation went to the same window within 60s), and
  `ollama-cleanup` post-processes transcripts with a local Ollama model (see Dictation
  below).
- **Neovim isn't in the repo.** Omarchy's `omarchy-nvim` package owns `~/.config/nvim`
  (restore with `omarchy-nvim-setup` / `omarchy-nvim-refresh`).

### `home/`

- **`.local/share/applications/discord.desktop`** overrides the `discord` package's
  launcher to force XWayland (`--ozone-platform=x11`). Omarchy's
  `ELECTRON_OZONE_PLATFORM_HINT=wayland` otherwise breaks Discord keybind recording.

### `config-linux/omarchy/` (Linux only)

- **`hooks/theme-set.d/vscode-reload-theme`**: makes VS Code live-reload Omarchy's
  generated "Omarchy" theme (used by themes without a `vscode.json`). It adds
  `"_watch": true` to `~/.vscode/extensions/omarchy-theme/package.json`, which VS Code
  reads only at startup, and touches the theme file after each switch, because VS Code
  otherwise keeps a loaded theme's colors cached. VS Code Settings Sync ignores
  `workbench.colorTheme` (set in VS Code, not the repo), so Omarchy machines follow the
  OS theme and others keep Monokai Pro. Temporary; see On update.
- **`hooks/theme-set.d/shared-wallpapers`**: symlinks
  `~/.config/omarchy/backgrounds/<theme-slug>` to `~/SyncDrive/images/Wallpapers` so the
  shared wallpapers appear in every theme (Omarchy has no all-themes folder). It leaves
  existing folders alone and does nothing without the SyncDrive folder. The hook runs
  after theme-set picks a background, so a theme's first switch won't include them.
- **`themes/monokai-nightfall-custom`**: a repo-owned copy of the krosdai Monokai
  Nightfall theme (source commit in its README). Edit its `colors.toml` (e.g.
  `hyprland_active_border` overrides `accent` for window borders), then
  `omarchy theme set monokai-nightfall-custom`. Omarchy treats a symlinked theme folder
  as the user's own, so it isn't restricted like a git-cloned theme (whose `.lua`,
  terminal configs and `vscode.json` are dropped) and `omarchy theme update` never
  pulls over it.

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
  `blacklist=` in `.config/MangoHud/MangoHud.conf` (mpv and Steam's shader
  pre-compiler `fossilize_replay` are already there).
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

## Dictation engine (voxtype + Parakeet)

`.config/voxtype/config.toml` uses the Parakeet engine (English-only, CUDA), loaded on
demand so it holds no VRAM between recordings. Parakeet needs voxtype's ONNX binary and the
model, so set both up per machine:

```
pkexec voxtype setup onnx --enable   # rewrites /usr/bin/voxtype to the ONNX (CUDA) binary
voxtype setup --download --model parakeet-tdt-0.6b-v2
systemctl --user restart voxtype
```

`voxtype setup onnx --disable` goes back to the Whisper (Vulkan) binary; set `engine = "whisper"` too.

## Dictation cleanup (voxtype + Ollama)

Voxtype pipes each transcript through `~/.config/voxtype/ollama-cleanup`, which fixes
punctuation, drops filler words, and applies self-corrections ("at 3, no wait, at 4")
with a small local model. It needs `ollama` (`ollama-cuda` on NVIDIA) and a one-time model
download per machine:

```
~/.config/voxtype/ollama-cleanup setup
systemctl --user restart voxtype
```

The script starts its own Ollama (`voxtype-ollama.service`) when recording starts and
stops it after 10 minutes without dictation, so the system `ollama.service` can stay
disabled. If Ollama isn't installed or the model is missing, dictation still works
with the raw transcript. Change the model with `model=` in the script, then re-run
`setup`.

## Suspend on NVIDIA (`omanir`, machine-local)

Suspend sometimes never happens: Xwayland gets stuck in the NVIDIA driver
(`kgmmuInvalidateTlb`), refuses to freeze, and the kernel gives up after ~4 minutes,
leaving the lock screen up. This is NVIDIA/open-gpu-kernel-modules#1329 (open modules
610.57.04, no fix yet). Details and history in `thoughts/nvidia-suspend-freeze.md`.

- **Experimental override:** `/etc/systemd/system/systemd-suspend.service.d/20-freeze-user-sessions.conf`
  sets `SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=true`, overriding `nvidia-utils`'
  `10-nvidia-no-freeze-session.conf`, so systemd freezes apps before the driver's kernel
  suspend notifier runs. Undo by deleting it and running `systemctl daemon-reload`. Remove
  it if the driver ever goes back to the `nvidia-suspend.service` (`nvidia-sleep.sh`) path,
  which needs user sessions left unfrozen.
- **Tell failures apart:** `journalctl -b -k | grep -E "Waking up from|Freezing user space processes failed"`.
  "Waking up from" with an immediate wake is a device wake (the chipset USB controller
  `0000:0d:00.0`, likely the Razer Naga); "Freezing … failed" is the driver hang.
- s2idle isn't an option: amdgpu rejects it ("BIOS has not been configured for suspend-to-idle").

## Windows VM

The Omarchy Windows VM (Install → Windows; a dockurr/windows container named
`omarchy-windows`) gets real GPU acceleration from the Ryzen iGPU, passed through with
VFIO. This is done on `omanir` (7800X3D iGPU `10:00.0` + HDMI audio `10:00.1`; the RTX 4090
drives the monitors). It's all machine-local: the full log, scripts and rollback are in
`thoughts/windows-vm-igpu-passthrough.md` and `thoughts/windows-vm-igpu/`.

**How it fits together:**
- **VM config.** `/var/lib/omarchy/windows/docker-compose.yml` is hand-edited to add
  `/dev/vfio/*`, an unlimited memlock and QEMU args that put the iGPU and its audio
  behind a PCIe root port. The iGPU gets its VBIOS from ACPI `VFCT` (`~/.windows/vbios_164e.rom`)
  and the audio function gets the isc30 AMD GOP ROM. Without the root port, Windows shows
  Code 43. Keep the file root-owned and not group/world-writable, or Omarchy refuses it. It
  holds the guest password.
- **iGPU hand-over.** The iGPU boots on `amdgpu` (only its audio is bound to `vfio-pci` at
  boot, by `/etc/modprobe.d/vfio-igpu.conf`). `/usr/local/bin/igpu-handover vm` moves it to
  `vfio-pci` before the VM starts, and `host` gives it back after. Moving it back re-initialises
  the GPU, which a suspend or a VM restart otherwise leaves broken. A polkit rule
  (`/etc/polkit-1/rules.d/50-igpu-handover.rules`) lets it run through `pkexec` without a password.
  After some sessions `amdgpu` can't re-initialise it (AMD reset bug, "PSP firmware loading
  failed"). That only affects Linux, which doesn't use the iGPU: the reset `vfio-pci` does when
  the VM starts is enough for Windows. So `igpu-handover` then leaves it on `vfio-pci` without
  any message, and only logs it (`journalctl -t igpu-handover`).
- **Hyprland stays off the iGPU.** `~/.config/uwsm/env.d/50-igpu-passthrough` sets
  `AQ_DRM_DEVICES=/dev/dri/dgpu`, a udev symlink to the 4090
  (`/etc/udev/rules.d/61-dgpu-symlink.rules`). `igpu-handover` refuses to bind `amdgpu` while
  Hyprland isn't pinned, since Hyprland would grab the iGPU and it couldn't be taken back.
- **Apps stay off the iGPU.** `/etc/udev/rules.d/72-igpu-root-only.rules` makes the iGPU's
  `/dev/dri` nodes root-only. Chromium/Electron apps (Discord, Signal, Steam, VS Code) open
  every GPU they can reach, which would block the hand-over. With the rule they only see the 4090.
  It also removes the iGPU from seat0, so logind won't hand it to Hyprland either: when `amdgpu`
  re-binds, Hyprland treats it as a hotplugged GPU and ignores `AQ_DRM_DEVICES`.
- **Launcher.** `~/.local/share/applications/windows-vm.desktop` execs `~/.local/bin/windows-vm-launch`
  (copy in `thoughts/windows-vm-igpu/`). It does the hand-over and makes a single
  `omarchy-windows-vm launch`, with an `xfreerdp3` stand-in that waits for the guest's RDP port. It also
  resets `~/Windows` to `0700`: Samba widens it (setgid or `0777`), which fails Omarchy's mount check. Only one
  copy runs at a time: clicking it while a session is open brings the RDP window forward (it may be on another
  workspace). Closing the RDP window shuts the VM down and hands the iGPU back. Re-running
  Omarchy's Install → Windows regenerates the `.desktop` file and drops the wrapper; point `Exec` back at it.
- **In the guest:** AMD Adrenalin (Ryzen 7000 graphics), the RDP "use hardware graphics adapter"
  policy, and [RadeonResetBugFix](https://github.com/inga-lovinde/RadeonResetBugFix) v0.1.7
  (`C:\Tools\RadeonResetBugFix`). That service disables the GPU when Windows shuts down and enables it at
  startup, so the GPU is left clean for the next start. If the adapter shows as disabled in
  Device Manager, the service didn't re-enable it at startup. Enabling it by hand then usually gives Code 43.

**If the VM won't start because "the iGPU is in use by: …":** something opened the iGPU
before the root-only rule applied (e.g. right after re-running the setup). Restart the named
apps, or reboot, and launch again. "Hyprland picked up the iGPU" means the seat part of the rule
wasn't in effect; log out and back in (or reboot).

**If Fusion falls back to software rendering (Code 43 on "AMD Radeon(TM) Graphics"):**
shut down the VM and launch it again, so the hand-over resets the iGPU. If that doesn't fix
it, reboot the host. Check where the iGPU is with `pkexec igpu-handover status`.

## Hyprdrive (overview + dock)

[Hyprdrive](https://github.com/dragosol/hyprdrive-omarchy) is a compiled Hyprland plugin
(tap Super for the overview, plus a dock), so it's installed per machine from a source
checkout rather than stowed. `hyprland.lua` requires `hypr.hyprdrive` only if
`~/.config/hypr/hyprdrive.lua` exists, so machines without it are unaffected. The installer
sees that `require` and doesn't append its own.

```bash
git clone https://github.com/dragosol/hyprdrive-omarchy.git ~/dev/hyprdrive-omarchy
cd ~/dev/hyprdrive-omarchy
git checkout "$(git tag --list 'v*' --sort=-v:refname | head -1)"   # latest release
make all && make install
hyprctl plugin load ~/.local/lib/hyprdrive/hyprdrive.so && hyprctl reload
```

`make install` writes only machine-local files: `~/.local/lib/hyprdrive/`, the loader
`~/.config/hypr/hyprdrive.lua`, fragments in `~/.config/hypr/hyprdrive/` (hand edits go below
`BEGIN raw-snippet`), and the settings panel in `~/.config/omarchy/plugins/dragos.hyprdrive/`.
Settings are in the bar's Hyprdrive panel.

**Update:** `git fetch --tags`, check out the newest tag, then
`rm -f hyprdrive.so ~/.local/lib/hyprdrive/hyprdrive.so && make all && make install`,
`omarchy restart shell`, and log out and back in. After a Hyprland update, if the plugin
fails with `[he] Version mismatch`, run `make clean && make all && make install`.

**Remove:** `make uninstall` in the checkout. It leaves the guarded `require` in
`hyprland.lua`, which then does nothing.

## On update

Things to check after updating Omarchy (`omarchy update`). Check the version with
`omarchy version`.

- **After a Hyprland update: rebuild Hyprdrive** (see above) if it fails with a version mismatch.

- **Past 4.0.4: remove the VS Code theme reload hook.** Omarchy 4.0.4's generated
  "Omarchy" VS Code theme doesn't reload when the theme changes
  ([#9336](https://github.com/omacom/omarchy/issues/9336)), so
  `config-linux/omarchy/hooks/theme-set.d/vscode-reload-theme` works around it.
  The fix ([PR #10134](https://github.com/omacom/omarchy/pull/10134)) was merged
  after 4.0.4. Once a newer release is installed, delete the hook and its entry
  under Config in the repo above, then remove the dangling link with
  `rm ~/.config/omarchy/hooks/theme-set.d/vscode-reload-theme`.
  Leaving the hook in place is harmless, but it does nothing useful after the fix.
