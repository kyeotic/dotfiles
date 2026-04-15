# app-ctl Distrobox

Ubuntu 24.04 distrobox for GUI-adjacent tools that need native display access but
can't be installed on Bazzite's immutable host OS.

## Apps

### espanso
Text expander with native Wayland support via EVDEVSource keyboard monitoring.
Config: `~/.config/espanso/` (stowed from `.config/espanso/`)
Service: `espanso.service`

### conky
Desktop system monitor (clock + stats) rendered via X11/XWayland.
Config: `~/.config/conky/` (stowed from `.config/conky/`)
Service: `conky.service` — runs two `podman exec` instances (clock + stats)

## Setup

Run once (idempotent):
```
~/dotfiles/bazzite/distrobox/app-ctl/setup
```

This is called automatically by `scripts/install_apps` on Linux.

What it does:
- Creates the `app-ctl` distrobox if absent
- Installs `espanso` (Wayland `.deb` from GitHub releases) and `conky-all`
- Installs a udev ACL rule so espanso can read `/dev/input/event*` inside the container

## Services

Enable and start:
```
systemctl --user enable --now espanso.service conky.service
```

Restart after config changes:
```
systemctl --user restart espanso.service
systemctl --user restart conky.service
```

Check logs:
```
journalctl --user -u espanso.service -f
journalctl --user -u conky.service -f
```

## Notes

- **Fonts** — Fira Code is available via distrobox's home directory mount; no install needed inside the box
- **nvidia-smi** — works inside the container via distrobox's host tool passthrough
- **Input access** — espanso uses a udev ACL rule (`setfacl` by UID) rather than the `input` group because podman drops supplementary groups inside the container
- **conky-box** — a legacy separate distrobox; can be removed with `distrobox rm conky-box` once conky is confirmed working in `app-ctl`
