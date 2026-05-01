# Fusion 360 on Bazzite Linux — Proton Method

**Goal:** Run Autodesk Fusion 360 on Bazzite via the cryinkfly installer script using Steam Proton (EM-10.0-34) inside a distrobox named `fusion360`.  
**Status:** Steps 1–5 complete. Fusion installed (v2702.1.47). Blocked on WebView2 SSO black screen.

**Why Proton instead of Wine:**  
The Wine path hit a wall — Wine 11.0 wow64 COM/RPC bugs, WebView2 int3 crashes, and display passthrough failures in `podman exec` stacked up. Proton (GE/EM variants) ships with tested patches for exactly this kind of Windows-app compatibility and has a known-working path via the cryinkfly installer.

---

## Key Facts

- **Proton available at:** `~/.local/share/Steam/compatibilitytools.d/`
  - `EM-10.0-34` (version string: `EM-10.0-34+`) ← use this
  - `Proton-GE Latest` (GE-Proton10-34)
- **Installer:** `autodesk_fusion_installer_x86-64.sh --proton=EM-10.0-34 --default`
- **Install destination:** `~/.autodesk_fusion/` (default)
- **Proton prefix:** `~/.autodesk_fusion/protonprefix/pfx/`
- **Fusion360.exe:** `~/.autodesk_fusion/protonprefix/pfx/drive_c/Program Files/Autodesk/webdeploy/production/6f81bda0bb0ebef0ea118cf2bd48cba17061ffb5/Fusion360.exe`
- **Installed version:** 2702.1.47 (deployed 2026-04-21)
- **Streamer log:** `~/.autodesk_fusion/protonprefix/pfx/drive_c/users/steamuser/AppData/Local/Autodesk/autodesk.webdeploy.streamer.log`
- **App log dir:** `~/.autodesk_fusion/protonprefix/pfx/drive_c/users/steamuser/AppData/Local/Autodesk/Neutron Platform/logs/`
- **`$HOME` is shared** between host and distrobox — Steam compat dir is accessible inside the container without extra mounts

---

## Execution Convention

Commands inside the distrobox **must** use `podman exec` with display env vars:
```bash
podman exec -u kyeotic \
  -e DISPLAY=:0 \
  -e WAYLAND_DISPLAY=wayland-1 \
  -e XDG_RUNTIME_DIR=/run/user/1000 \
  -e XAUTHORITY=/run/user/1000/xauth_YWPRXU \
  fusion360 bash -c '...'
```

**XAUTHORITY is required** — without it, Wine processes get "Authorization required" and can't connect to X.

Do NOT use `distrobox enter fusion360 -- bash -c '...'`.

Note: `XAUTHORITY` path changes each session. Always check with `echo $XAUTHORITY` on the host before running.

---

## Step 1: Remove old container if it exists ✅ DONE

The old `fusion360` Wine container was absent. No action needed.

---

## Step 2: Create new distrobox ✅ DONE

```bash
distrobox create --name fusion360 --image ubuntu:24.04
distrobox enter fusion360 -- bash -c 'echo ready'
```

**Do NOT add:**
- `--init` — causes a fatal sd-bus/polkit error on Bazzite
- `--volume /run/user/1000:/run/user/1000:rw` — distrobox auto-mounts this; explicit mount fails with "duplicate mount destination"

---

## Step 3: Install dependencies inside container ✅ DONE

Also required (not in original list — installer exits without them):
- `mokutil` — installer exits with "mokutil command not found" if missing
- `gettext` — needed for installer UI messages
- `pciutils` — needed for `lspci` GPU detection

```bash
podman exec -u kyeotic fusion360 bash -c '
  sudo apt-get update -qq
  sudo apt-get install -y \
    gawk cabextract coreutils curl lsb-release mesa-utils \
    p7zip p7zip-full p7zip-rar policykit-1 samba spacenavd \
    winbind wget xdg-utils bc x11-xserver-utils desktop-file-utils \
    python3 python3-pip mokutil gettext pciutils
'
```

---

## Step 3b: Create nvidia-smi stub ✅ DONE

The host `nvidia-smi` binary (`/run/host/usr/bin/nvidia-smi`) segfaults inside the Ubuntu container due to glibc ABI mismatch. The installer requires `nvidia-smi` to detect VRAM. Create a stub:

```bash
podman exec -u kyeotic fusion360 bash -c '
  sudo tee /usr/local/bin/nvidia-smi > /dev/null <<'"'"'EOF'"'"'
#!/bin/bash
# Stub for installer GPU detection - RTX 4090 (24564 MB VRAM)
for arg in "$@"; do
  if [[ "$arg" == *"memory.total"* ]]; then
    echo "24564"
    exit 0
  fi
done
echo "NVIDIA GeForce RTX 4090"
exit 0
EOF
  sudo chmod +x /usr/local/bin/nvidia-smi
'
```

**Why:** GPU is an RTX 4090 (confirmed via `lspci`). The installer uses `nvidia-smi` to detect VRAM and exits with "Invalid input" if GPU detection fails entirely.

---

## Step 4: Download the installer script ✅ DONE

```bash
podman exec -u kyeotic fusion360 bash -c '
  wget -q "https://codeberg.org/cryinkfly/Autodesk-Fusion-360-on-Linux/raw/branch/main/files/setup/autodesk_fusion_installer_x86-64.sh" \
    -O /home/kyeotic/autodesk_fusion_installer.sh
  chmod +x /home/kyeotic/autodesk_fusion_installer.sh
'
```

---

## Step 5: Run installer with Proton ✅ DONE

```bash
podman exec -u kyeotic \
  -e DISPLAY=:0 \
  -e WAYLAND_DISPLAY=wayland-1 \
  -e XDG_RUNTIME_DIR=/run/user/1000 \
  -e XAUTHORITY=/run/user/1000/xauth_YWPRXU \
  fusion360 bash -c '
    cd /home/kyeotic
    ./autodesk_fusion_installer.sh --proton=EM-10.0-34 --default
  '
```

**What happened:**
- Installer asked for a pkexec password dialog on desktop — approved it
- Wine Staging 11.7 installed (winehq-noble repo, ~486MB)
- Proton prefix initialized at `~/.autodesk_fusion/protonprefix/`
- DXVK 2.7.1 installed (d3d8/9/10/11 + dxgi for x32 and x64)
- WebView2 runtime installed (but see WebView2 issue below)
- Qt6WebEngineCore.dll patched (Wayland white-screen fix)
- siappdll.dll patched
- FusionClientInstaller.exe downloaded and run — Fusion streamer downloaded v2702.1.47

**Note:** The streaming installer ran but required a GUI click on the splash screen to proceed. Make sure DISPLAY and XAUTHORITY are set correctly.

**Streamer log path (for monitoring download):**
```bash
tail -f ~/.autodesk_fusion/protonprefix/pfx/drive_c/users/steamuser/AppData/Local/Autodesk/autodesk.webdeploy.streamer.log
```

---

## Step 6: Launch Fusion

```bash
FUSION_EXE=$(find ~/.autodesk_fusion/protonprefix/pfx/drive_c/Program\ Files/Autodesk/webdeploy/production -name "Fusion360.exe" | head -1)

podman exec -u kyeotic \
  -e DISPLAY=:0 \
  -e WAYLAND_DISPLAY=wayland-1 \
  -e XDG_RUNTIME_DIR=/run/user/1000 \
  -e XAUTHORITY=/run/user/1000/xauth_YWPRXU \
  -e PROTON_LOG=0 \
  -e STEAM_COMPAT_CLIENT_INSTALL_PATH=/home/kyeotic/.local/share/Steam \
  -e STEAM_COMPAT_DATA_PATH=/home/kyeotic/.autodesk_fusion/protonprefix \
  -e WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS="--no-sandbox --disable-gpu --disable-gpu-sandbox" \
  fusion360 bash -c "
    ~/.local/share/Steam/compatibilitytools.d/EM-10.0-34/proton run '$FUSION_EXE'
  " &
```

---

## Current Blocker: WebView2 SSO Black Screen

**Status:** Fusion launches and shows "Signing in" window, but it is completely black. `msedgewebview2.exe` never spawns.

**What we know:**
- The "Signing in" window appears (X11 auth is working, DISPLAY passthrough works)
- `msedgewebview2.exe` subprocess never starts — no process appears in `ps aux`
- WebView2 installed version is **129.0.2792.65** (not the pinned 109.0.1518.78 the cryinkfly installer intended) — the Fusion streaming installer overwrote the pinned version
- Attempting to reinstall the pinned `WebView2installer.exe` (~140MB from downloads) did not downgrade to 109
- `HKCU\Software\Microsoft\Edge\WebView2\AdditionalBrowserArguments = --no-sandbox --disable-gpu --disable-gpu-sandbox` (registry) — had no effect
- `WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS` env var — had no effect
- GPU: RTX 4090 via DXVK, `/dev/nvidia0` visible in container, GL libs present

**Likely cause:** WebView2 129 uses a GPU/sandbox process that either crashes immediately in the container or is blocked by Proton's seccomp. The renderer process never reaches the point of drawing.

**Things to try next:**
1. Enable Proton logging (`PROTON_LOG=1`) and grep for WebView2 process creation failures
2. Try `PROTON_USE_WINED3D=1` (disables DXVK, uses software D3D) — might unblock WebView2 GPU process
3. Try running `msedgewebview2.exe` directly via wine to see raw error
4. Try forcing WebView2 to use swiftshader: `--use-angle=swiftshader --use-gl=swiftshader`
5. Try GE-Proton instead of EM-Proton (GE-Proton10-34 is also available)
6. Check for crash dumps in `~/.autodesk_fusion/protonprefix/pfx/drive_c/users/steamuser/AppData/Local/Temp/`
7. Check if WebView2 can be forced to use version 109 by manually placing it

---

## Known Issues / Potential Blockers

| Issue | Workaround |
|---|---|
| Wayland white screen | Installer auto-applies Qt6WebEngineCore.dll patch (Step 5) ✅ |
| WebView2 crash | Installer pins 109.0.1518.78 — but streaming installer overwrites with 129 |
| SSO login black screen | **Current blocker** — see above |
| `/dev/input` access for SpaceMouse | udev ACL rule (setfacl by UID) — see memory |
| `WAYLAND_DISPLAY=wayland-1` wrong | Check host: `echo $WAYLAND_DISPLAY` — may be `wayland-0` |
| `mokutil` missing | Install in Step 3 — installer exits without it |
| `lspci` missing → GPU not detected | Install `pciutils` in Step 3 |
| `nvidia-smi` segfaults in container | Create stub (Step 3b) — host binary has glibc ABI mismatch |
| `winetricks-patched` not found | Non-fatal apt error — installer continues |
| systemctl/spacenavd fails | Non-fatal — no systemd in container, skipped |
| `XAUTHORITY` not set | Always pass `-e XAUTHORITY=$XAUTHORITY` to podman exec |

---

## Progress Log

- [x] Old `fusion360` container removed (was absent)
- [x] New distrobox created (ubuntu:24.04, name=fusion360)
- [x] Dependencies installed (including mokutil, gettext, pciutils)
- [x] nvidia-smi stub created
- [x] Installer script downloaded
- [x] Installer run with `--proton=EM-10.0-34 --default`
- [x] Fusion streamed and installed (v2702.1.47, production dir exists)
- [x] Fusion360.exe launches (splash + "Signing in" window appear)
- [ ] SSO login works ← **BLOCKED: WebView2 black screen**
- [ ] App fully functional
- [ ] Desktop entry exported
