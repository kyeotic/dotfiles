# OBS + Bambu Camera on Bazzite Linux

Stream the Bambu printer camera into OBS as a virtual camera source for Discord.

## How it works

1. **v4l2loopback** creates two virtual video devices:
   - `/dev/video10` — "Bambu Cam": ffmpeg writes the printer stream here; OBS reads it as a source
   - `/dev/video11` — "OBS Virtual Camera": OBS writes its virtual camera output here; Discord reads from it

2. **ffmpeg** connects to the printer's local RTSP stream over TLS and pipes decoded frames into `/dev/video10`

3. **OBS** reads `/dev/video10` as a Video Capture Device source and outputs to `/dev/video11` via its Virtual Camera feature

4. **obs-bambu** is a wrapper script that ties the lifecycle together: ffmpeg runs only while OBS is open

## Prerequisites

- v4l2loopback 0.15.3 (bundled with Bazzite)
- ffmpeg (`ffmpeg` system package)
- OBS Studio Flatpak (`com.obsproject.Studio`)

## Setup

### 1. Sudoers rule (passwordless modprobe)

Allows the wrapper script to load v4l2loopback without a password prompt.

```bash
echo 'kyeotic ALL=(root) NOPASSWD: /sbin/modprobe v4l2loopback *' | sudo tee /etc/sudoers.d/v4l2loopback
sudo chmod 440 /etc/sudoers.d/v4l2loopback
```

### 2. Wrapper script — `~/.local/bin/obs-bambu`

Starts ffmpeg before OBS, kills it when OBS exits.

```bash
#!/usr/bin/env bash
# Launch OBS with Bambu camera feed via v4l2loopback.
# ffmpeg streams the printer camera to /dev/video10 while OBS is open,
# and is killed automatically when OBS exits.

set -euo pipefail

RTSP_URL="rtsps://bblp:3fc7c411@192.168.0.83:322/streaming/live/1"
V4L2_DEVICE="/dev/video10"
FFMPEG_PID=""

cleanup() {
    if [[ -n "$FFMPEG_PID" ]] && kill -0 "$FFMPEG_PID" 2>/dev/null; then
        echo "Stopping Bambu camera stream (PID $FFMPEG_PID)..."
        kill "$FFMPEG_PID"
        wait "$FFMPEG_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

# Ensure v4l2loopback is loaded with both devices
if ! v4l2-ctl --list-devices 2>/dev/null | grep -q "Bambu Cam"; then
    echo "Loading v4l2loopback devices..."
    sudo modprobe v4l2loopback \
        devices=2 \
        video_nr=10,11 \
        card_label="Bambu Cam,OBS Virtual Camera" \
        exclusive_caps=1
fi

# Start the camera stream
echo "Starting Bambu camera stream -> $V4L2_DEVICE"
ffmpeg -loglevel warning \
    -rtsp_transport tcp \
    -i "$RTSP_URL" \
    -vf scale=1168:720 \
    -pix_fmt yuv420p \
    -f v4l2 "$V4L2_DEVICE" &
FFMPEG_PID=$!

echo "Launching OBS (ffmpeg PID: $FFMPEG_PID)..."
flatpak run com.obsproject.Studio "$@"

# OBS exited — trap fires cleanup automatically
```

Make it executable:

```bash
chmod +x ~/.local/bin/obs-bambu
```

### 3. Desktop entry — `~/.local/share/applications/obs-bambu.desktop`

Makes `obs-bambu` appear in the KDE app launcher so it can be pinned to the taskbar.

```ini
[Desktop Entry]
Name=OBS (Bambu Camera)
Comment=OBS Studio with Bambu printer camera stream
Exec=obs-bambu
Icon=com.obsproject.Studio
Terminal=false
Type=Application
Categories=AudioVideo;Recorder;
```

To pin: open the KDE app launcher, search "OBS (Bambu Camera)", right-click → Pin to Taskbar.

### 4. OBS scene configuration

- Add source: **Video Capture Device (V4L2)** → `/dev/video10` (Bambu Cam), 1168×720, 30fps
- With source selected, press `Ctrl+F` to fit it to the canvas
- To stream to Discord: **Start Virtual Camera** → select "OBS Virtual Camera" in Discord's camera picker

## Printer details

| Field             | Value                            |
| ----------------- | -------------------------------- |
| Local IP          | 192.168.0.83 (DHCP — may change) |
| RTSP port         | 322                              |
| Username          | `bblp`                           |
| Access code       | `3fc7c411`                       |
| Stream resolution | 1168×720 @ 30fps, H264           |

> **Note:** The printer IP is not a static lease. If the stream stops connecting, check the current IP in Bambu Studio and update `RTSP_URL` in `~/.local/bin/obs-bambu`.

## Troubleshooting

**ffmpeg exits immediately after starting OBS**
Check that `/dev/video10` exists: `v4l2-ctl --list-devices`. If "Bambu Cam" is missing, the modprobe step failed — run it manually and check `dmesg` for errors.

**Virtual camera fails to start in OBS**
Both `/dev/video10` and `/dev/video11` must exist before OBS opens. If only one device was created, the module options didn't apply — remove and reload:
```bash
sudo modprobe -r v4l2loopback
sudo modprobe v4l2loopback devices=2 video_nr=10,11 card_label="Bambu Cam,OBS Virtual Camera" exclusive_caps=1
```

**Stream connects but shows black screen**
The printer IP may have changed. Find the new IP in Bambu Studio and update `RTSP_URL` in `~/.local/bin/obs-bambu`.

**Why not use Bambu Studio's built-in Go Live?**
The Go Live feature uses a helper binary (`bambu_source`) that has a known bug in the Flatpak sandbox — it connects but outputs a black screen. The direct RTSP approach bypasses it entirely.
