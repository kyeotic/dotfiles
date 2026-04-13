# KWin Scripting on Bazzite (KDE 6 / Plasma 6)

## Overview

Two complementary tools are used for window snapping:
- **KZones** — snaps windows within the current monitor using drag-and-drop or keyboard shortcuts
- **window-snap** — custom KWin script that moves windows to the secondary monitor

---

## KZones Layout (`~/.config/kwin/kzone.json`)

Zones are percentage-based and relative to the screen the window is currently on.
They **cannot target a different monitor** — each zone applies to whichever monitor the window is on.

Current layout: `"Multi-Monitor"` (first entry, picked up by default)

| Zone | Purpose | x | y | w | h |
|------|---------|---|---|---|---|
| 1 | Main monitor ~90% centered | 5 | 5 | 90 | 90 |
| 2 | Monitor 2 top half (conky buffer) | 15 | 0 | 85 | 50 |
| 3 | Monitor 2 bottom half (conky buffer) | 15 | 50 | 85 | 50 |
| 4 | Monitor 2 full height (conky buffer) | 15 | 0 | 85 | 100 |

Zones 2–4 are defined but do nothing useful from monitor 1 — cross-monitor movement requires the window-snap script (see below).

---

## window-snap Script (`~/.config/kwin/scripts/window-snap/`)

Custom KWin script that snaps the active window to the primary monitor (centered) or to regions of the **rightmost screen** (secondary monitor), with a 100px top buffer on the secondary screen.

### Shortcuts

| Shortcut | Action |
|----------|--------|
| `Meta+1` | Primary monitor — 90% centered |
| `Meta+2` | Secondary monitor — top half (below 100px buffer) |
| `Meta+3` | Secondary monitor — bottom half (below 100px buffer) |
| `Meta+4` | Secondary monitor — full height (below 100px buffer) |

### Top buffer

A fixed **100px top buffer** (`topBuffer = 100`) is applied to all secondary-monitor placements. The secondary screen is treated as if it starts 100px from the top — full, top-half, and bottom-half are all relative to the usable area below that buffer. Adjust `topBuffer` in `contents/ui/main.qml` if needed.

### Secondary screen detection

The script finds the secondary monitor dynamically by picking the screen with the highest X offset (rightmost). No hardcoded screen names.

---

## Critical KDE 6 Learnings

### Pure JS KWin scripts (`registerShortcut`) do not work in KDE 6

The old pure-JS KWin script API (`registerShortcut()` in `contents/code/main.js`) registers shortcuts visibly in System Settings but **the callbacks never fire** in KDE 6 / Plasma 6.

**Fix: rewrite as a QML declarative script.**

### Required metadata.json fields for KDE 6

```json
{
  "KPackageStructure": "KWin/Script",
  "KPlugin": {
    "ServiceTypes": ["KWin/Script"],
    ...
  },
  "X-Plasma-API": "declarativescript",
  "X-Plasma-API-Minimum-Version": "6.0",
  "X-Plasma-MainScript": "ui/main.qml"
}
```

Without `X-Plasma-API: "declarativescript"`, KDE 6 treats the script as legacy JS and shortcuts don't fire.

### Use `ShortcutHandler` in QML, not `registerShortcut()`

```qml
import QtQuick
import org.kde.kwin

Item {
    ShortcutHandler {
        name: "MyScript: Action Name"
        text: "MyScript: Action Name"
        sequence: "Meta+2"
        onActivated: doSomething()
    }
}
```

### Always call `setMaximize` before setting `frameGeometry`

```js
client.setMaximize(false, false)
client.frameGeometry = Qt.rect(x, y, w, h)
```

If the window is in any maximized state, the `frameGeometry` assignment is **silently ignored** by the compositor. Learned from KZones source (`moveClientToZone()` in main.qml).

### Use `Workspace` (capital W) in QML declarative scripts

In QML scripts, global objects use capital W: `Workspace.activeWindow`, `Workspace.screens`.
The lowercase `workspace` is the legacy pure-JS API.

---

## File Layout

```
~/.config/kwin/
├── kzone.json                          # KZones layout config
└── scripts/window-snap/
    ├── metadata.json                   # Must declare declarativescript + Plasma 6.0
    └── contents/ui/
        └── main.qml                   # QML entry point with ShortcutHandler
```

## Reloading After Changes

Depends on what changed:

- **Geometry tweaks** (buffer sizes, fractions, positions) — reload just the script via D-Bus:
  ```bash
  qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "window-snap" && \
  qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "/home/kyeotic/.config/kwin/scripts/window-snap" "window-snap"
  ```
  This unloads and reloads the script in-place. No KWin restart, no app disruption. **Do not use `kwin_wayland --replace`** — it restarts the compositor and disrupts running apps.

- **New or renamed shortcuts** — log out and back in. `kglobalshortcutsrc` only picks up new `ShortcutHandler` entries at session start; a KWin restart alone is not enough.
