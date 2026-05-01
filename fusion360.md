# Fusion 360 on Bazzite Linux

**Goal:** Run Autodesk Fusion 360 on Bazzite (immutable Fedora-based) via distrobox + Wine.  
**Status:** In Progress — Wine 11.0 installed, dotnet452 ✓, WebView2 bypassed via fake registry keys, installer extracts and runs streamer, final blocker is display passthrough in `podman exec`

Use agents to do work (to limit context exposure across commands) and coordinate progress back into this document.

---

## Execution Convention

**ALL commands inside the container must use `podman exec` with `-u kyeotic` and display env vars:**
```bash
podman exec -u kyeotic \
  -e WINEPREFIX=/home/kyeotic/.wine-fusion360 \
  -e WINEARCH=win64 \
  -e DISPLAY=:0 \
  -e WAYLAND_DISPLAY=wayland-1 \
  -e XDG_RUNTIME_DIR=/run/user/1000 \
  fusion360 wine /path/to/something.exe
```

**Critical:** Without `-e XDG_RUNTIME_DIR=/run/user/1000` and the display vars, Wine fails silently with "no driver could be loaded" — installer shows no window, streamer never starts.

Do NOT use `distrobox enter fusion360 -- bash -c '...'`.

---

## Current State (start of next session)

- **Wine version:** 11.0 (from WineHQ plucky repo)
- **WINEPREFIX:** `~/.wine-fusion360` (win64, Windows 10)
- **Installer:** `/tmp/Fusion360installer.exe` — may be gone (recheck; re-download from `https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe`)
- **WebView2 fake registry keys:** present at `HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}` with `pv = 129.0.2792.65` — verified surviving reboots
- **Temp archives:** Multiple 7z temp dirs in `~/.wine-fusion360/drive_c/users/kyeotic/Temp/` (7zS*.tmp, ~1.5 GB each) — safe to wipe all before fresh run
- **Production dir:** `~/.wine-fusion360/drive_c/Program Files/Autodesk/webdeploy/production/` — likely empty or partial; wipe before fresh run
- **Meta registry:** `~/.wine-fusion360/drive_c/Program Files/Autodesk/webdeploy/meta/` — wipe before fresh run to avoid "Non patched update" errors

### Next step: Re-run installer with correct display passthrough

```bash
# 1. Wipe partial state
podman exec -u kyeotic fusion360 bash -c '
  rm -rf "/home/kyeotic/.wine-fusion360/drive_c/Program Files/Autodesk/webdeploy/production/"*
  rm -rf "/home/kyeotic/.wine-fusion360/drive_c/Program Files/Autodesk/webdeploy/meta/"*
  rm -rf /home/kyeotic/.wine-fusion360/drive_c/users/kyeotic/Temp/7zS*.tmp
'

# 2. Verify/re-download installer
podman exec -u kyeotic fusion360 bash -c 'ls -lh /tmp/Fusion360installer.exe 2>/dev/null || wget -q "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe" -O /tmp/Fusion360installer.exe'

# 3. Run installer with full display passthrough
podman exec -u kyeotic \
  -e WINEPREFIX=/home/kyeotic/.wine-fusion360 \
  -e WINEARCH=win64 \
  -e DISPLAY=:0 \
  -e WAYLAND_DISPLAY=wayland-1 \
  -e XDG_RUNTIME_DIR=/run/user/1000 \
  fusion360 wine /tmp/Fusion360installer.exe
```

**Watch log for progress:**
```bash
podman exec -u kyeotic fusion360 tail -f \
  /home/kyeotic/.wine-fusion360/drive_c/users/kyeotic/AppData/Local/Autodesk/autodesk.webdeploy.streamer.log \
  | grep -E "WebView2|ERROR|Aborted|special action|FusionLauncher|launcher\.ini"
```

---

## Method 1: Distrobox + WineHQ

Based on [issue #557](https://github.com/cryinkfly/Autodesk-Fusion-360-for-Linux/issues/557) which documents this exact Bazzite/immutable-Linux path.

### Step 1: Create the distrobox container ✅

```bash
distrobox create \
  --name fusion360 \
  --image ubuntu:25.10 \
  --volume /run/user/1000:/run/user/1000:rw \
  --init \
  --additional-flags "--security-opt label=disable"
```

### Step 2: Install Wine 11.0 ✅

Wine 11.0 is installed from WineHQ plucky repo. Earlier we used Wine 9.0 (dotnet452 install required it), but Wine 11.0 is needed because the Fusion streamer bundles **Python 3.14** which calls `CopyFile2` — unimplemented in Wine 9.0 64-bit.

```bash
# Current state: wine-11.0 from WineHQ plucky is installed
podman exec -u kyeotic fusion360 wine --version  # → wine-11.0
```

**Wine version history for this project:**
- Wine 9.0 was required to install dotnet452 (Wine 10+/11 wow64 COM/RPC bug broke install)
- dotnet452 is already installed in the prefix
- Wine 11.0 is now running — CopyFile2 is implemented, wow64 COM bug doesn't affect Fusion's 64-bit components

### Step 3: Configure Wine prefix ✅

```bash
export WINEPREFIX=~/.wine-fusion360
export WINEARCH=win64
wine wineboot --init
winetricks -q win10
```

### Step 4: Install .NET and VC++ dependencies ✅

```bash
winetricks -q atmlib gdiplus corefonts vcrun2017 dotnet452
```
All installed successfully under Wine 9.0. Prefix retains these with Wine 11.0.

### Step 5: WebView2 bypass ✅

WebView2 installer (`setup.exe` i386 guest) crashes with `int3` under Wine on both 9.0 and 11.0 — this is a fundamental Wine limitation.

**Workaround: Fake the registry keys** so the Fusion streamer thinks WebView2 is already installed:
```bash
wine reg add "HKLM\\SOFTWARE\\WOW6432Node\\Microsoft\\EdgeUpdate\\Clients\\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /v pv /t REG_SZ /d "129.0.2792.65" /f
wine reg add "HKLM\\SOFTWARE\\Microsoft\\EdgeUpdate\\Clients\\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /v pv /t REG_SZ /d "129.0.2792.65" /f
wine reg add "HKCU\\SOFTWARE\\Microsoft\\EdgeUpdate\\Clients\\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /v pv /t REG_SZ /d "129.0.2792.65" /f
```
Streamer log then shows: `WebView2 found in Local Machine → Install WebView2 succeeded` (skipped).

### Step 6: Run Fusion installer (IN PROGRESS)

**Correct installer URL** (Autodesk rebranded from "Fusion 360" to "Fusion" in 2024):
```
https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe
```
Old URL with "360" in the path returns 404.

**Known issues during install:**
- Installer runs silently (no window) if `XDG_RUNTIME_DIR` / display vars not passed to `podman exec` — **this is the current blocker**
- The streamer needs to run fully to completion to create `FusionLauncher.exe.ini` and complete post-deploy tasks
- Partial installs cause "Non patched update" errors on re-run — always wipe `production/` and `meta/` before retrying

**What a successful run looks like in the streamer log:**
1. `WebView2 found in Local Machine` (fake keys detected, WebView2 skipped)
2. `UPDATE_IDSDK_CONFIG` (SSO config updated)
3. File association warnings for `.f3d`, `.f3z` etc. (non-fatal, Wine can't export non-existent keys)
4. `UPDATE_PINNABLE_LAUNCHER` (desktop shortcut created)
5. `Complete perform postdeploy tasks` — at this point `FusionLauncher.exe.ini` should exist

### Step 7: Apply DLL fixes (PENDING)

After install completes, two DLLs need replacement:

**Qt6WebEngineCore.dll** — replace with patched version from cryinkfly project to fix Wayland white screen:
```bash
# Find patched DLL in cryinkfly releases
HASH=$(ls "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production/")
wget <qt6webenginecore-patched-url> -O Qt6WebEngineCore.dll
cp Qt6WebEngineCore.dll "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production/$HASH/"
```

**bcp47langs:**
```bash
winetricks -q bcp47langs
```

### Step 8: Configure DXVK (PENDING)

```bash
winetricks dxvk
```

### Step 9: Launch Fusion (PENDING)

```bash
HASH=$(ls "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production/")
wine "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production/$HASH/FusionLauncher.exe"
# or
wine "$WINEPREFIX/drive_c/Program Files/Autodesk/webdeploy/production/$HASH/Fusion360.exe"
```

---

## Active Blockers

### Display passthrough in `podman exec`

`podman exec` doesn't inherit the session's display environment. Without `XDG_RUNTIME_DIR`, Wine outputs:
```
error: XDG_RUNTIME_DIR is invalid or not set in the environment.
nodrv_CreateWindow: Make sure that your display server is running and that its variables are set.
```
This causes the installer to run silently with no window, and the streamer never starts.

**Fix:** Pass all display vars explicitly:
```bash
podman exec -u kyeotic \
  -e DISPLAY=:0 \
  -e WAYLAND_DISPLAY=wayland-1 \
  -e XDG_RUNTIME_DIR=/run/user/1000 \
  fusion360 ...
```
The `WAYLAND_DISPLAY` value and whether it's `wayland-0` or `wayland-1` needs to be confirmed from the host environment.

---

## Known Issues / Potential Blockers

| Issue | Workaround |
|---|---|
| Wayland crash / white screen | Qt6WebEngineCore.dll replacement (Step 7) |
| SSO login fails | WebView2 is bypassed via fake keys; app may need workaround for login |
| `/dev/input` access for SpaceMouse | udev ACL rule (setfacl by UID) — see memory |
| spacenavd not starting | `sudo systemctl enable --now spacenavd` inside container |
| Wine graphics glitches | DXVK + Vulkan drivers on host |
| Multiple stale Wine sessions | Kill all with `wineserver -k` before fresh run |

---

## Progress Log

- [x] Container created — ubuntu:25.10 (codename: questing), name=fusion360
- [x] Wine 9.0 installed (jammy packages) — needed for dotnet452 install
- [x] Winetricks and samba installed
- [x] winetricks dependencies — atmlib/gdiplus/corefonts/vcrun2017/dotnet452 ✓
- [x] Wine prefix set to Windows 10
- [x] Wine upgraded to 11.0 — needed for CopyFile2 (Python 3.14 in streamer)
- [x] WebView2 bypassed — fake registry keys at HKLM WOW6432Node EdgeUpdate pv=129.0.2792.65
- [~] Fusion installer — streamer runs and extracts packages, but **display passthrough not working in podman exec** (next blocker)
- [ ] FusionLauncher.exe.ini created (post-install completion)
- [ ] DLL fixes applied (Qt6WebEngineCore, bcp47langs)
- [ ] DXVK configured
- [ ] App launches
- [ ] SSO login works
- [ ] Desktop entry exported

---

## RESOLVED Issues

### Wine 11.0 wow64 COM/RPC bug
Wine 11.0 (and 10.x) have broken COM/RPC for 32-bit (wow64) processes. This caused dotnet452 to fail with "class not registered" and WebView2 to fail with `err:ole:start_rpcss Failed to open RpcSs service`.

**Resolution for dotnet452:** Installed under Wine 9.0 first. Prefix retains the installed assemblies after upgrading to Wine 11.0. The wow64 COM bug doesn't affect Fusion's 64-bit components.

### WebView2 int3 crash
WebView2 `setup.exe` (i386 guest) crashes with `int3` under Wine 9.0 and 11.0. Both the standalone installer and the version bundled in the Fusion installer hit this crash.

**Resolution:** Fake registry keys trick the Fusion streamer into thinking WebView2 is already installed (it skips installation and continues).

### CopyFile2 unimplemented (Wine 9.0)
The Fusion streamer bundles Python 3.14, which calls `KERNEL32.dll.CopyFile2` — stubbed but unimplemented in Wine 9.0 64-bit.

**Resolution:** Upgraded Wine to 11.0 where CopyFile2 is implemented.

### Installer URL changed
Old URL `Fusion%20360%20Admin%20Install.exe` returns 404. Autodesk rebranded to "Fusion" (dropped "360") in early 2024.

**Resolution:** Use `Fusion%20Admin%20Install.exe` (without "360").
