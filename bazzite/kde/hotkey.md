# KDE Panel Visibility Hotkey

**Hotkey:** `Meta+F8`  
**Action:** Toggles panel between Always Show (`none`) and Dodge Windows (`dodgewindows`)

## How it works

A KWin JS script (`toggle-panel`) registers the shortcut via `registerShortcut` and calls
`callDBus` → `org.kde.PlasmaShell.evaluateScript` to toggle panel visibility live.
No plasmashell restart, no flicker.

**Why JS not QML:** `callDBus` does not exist in KWin 6's declarative (QML) scripting
context. QML scripts only have access to KWin's own `Workspace` APIs. Since toggling a
Plasma panel requires calling into Plasmashell via DBus, the script must be a KWin JS
script. The `window-snap` script is QML because it only uses `Workspace` APIs.

## Gotchas

**Shortcut conflict:** Check `~/.config/kglobalshortcutsrc` for a stale
`[services][toggle-panel-visibility.desktop]` section with `_launch=Meta+F8`. Remove it:

```bash
kwriteconfig6 --file kglobalshortcutsrc \
  --group "services" --group "toggle-panel-visibility.desktop" \
  --key "_launch" --delete
```

**reconfigure doesn't reload scripts:** `qdbus org.kde.KWin /KWin reconfigure` does NOT
unload already-running scripts. If you change the script type (e.g. QML → JS), a full
KWin restart is required. Otherwise the old script instance keeps running.

**Both QML and JS present:** If `contents/ui/main.qml` exists alongside
`contents/code/main.js`, KWin may load the QML file first and never reach the JS file.
Always remove stale script files when switching formats.

## Panel hiding values (Plasma 6 uses strings, not integers)

- `none` = Always Show
- `autohide` = Auto Hide
- `dodgewindows` = Dodge Windows
- `dodgeactive` = Dodge Active Window

## Files

| File | Purpose |
|------|---------|
| `.config/kwin/scripts/toggle-panel/metadata.json` | KWin script package metadata |
| `.config/kwin/scripts/toggle-panel/contents/code/main.js` | Script — registers shortcut and calls DBus |

## Setup after fresh install

```bash
~/dotfiles/scripts/stow
/usr/bin/kwriteconfig6 --file kwinrc --group Plugins --key toggle-panelEnabled true
# Hot-load without rebooting (use loadScript for JS scripts, not loadDeclarativeScript):
dbus-send --session --dest=org.kde.KWin --print-reply /Scripting \
  org.kde.kwin.Scripting.loadScript \
  string:/home/kyeotic/.local/share/kwin/scripts/toggle-panel/contents/code/main.js \
  string:toggle-panel
# After next KWin restart it autoloads from kwinrc
```

After reboot, KWin autoloads from `~/.local/share/kwin/scripts/toggle-panel`
(symlinked by `scripts/stow`) based on the `toggle-panelEnabled=true` entry in `kwinrc`.
The `X-Plasma-API: javascript` field in `metadata.json` is required for auto-loading —
without it KWin silently skips the script.
