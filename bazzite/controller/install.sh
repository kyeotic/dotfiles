#!/usr/bin/env bash
# Installs the 8BitDo PTT pass-through script, systemd service, toggle hotkey, and KDE shortcut.
# Idempotent: safe to re-run after any change to the .py or .service file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine the real user even when run via sudo.
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

run_as_user() {
    sudo -u "$REAL_USER" "$@"
}

echo "==> Installing 8bitdo-ptt service..."
install -m 755 "$SCRIPT_DIR/8bitdo-ptt.py" /usr/local/bin/8bitdo-ptt.py
install -m 644 "$SCRIPT_DIR/8bitdo-ptt.service" /etc/systemd/system/8bitdo-ptt.service

systemctl daemon-reload
systemctl enable 8bitdo-ptt
systemctl restart 8bitdo-ptt

echo "==> Installing toggle script..."
install -m 755 "$SCRIPT_DIR/8bitdo-ptt-toggle.sh" /usr/local/bin/8bitdo-ptt-toggle.sh

echo "==> Installing sudoers drop-in..."
install -m 440 "$SCRIPT_DIR/8bitdo-ptt-sudoers" /etc/sudoers.d/8bitdo-ptt
visudo -cf /etc/sudoers.d/8bitdo-ptt

echo "==> Installing .desktop file..."
DESKTOP_DIR="$REAL_HOME/.local/share/applications"
run_as_user mkdir -p "$DESKTOP_DIR"
install -m 644 -o "$REAL_USER" "$SCRIPT_DIR/8bitdo-ptt-toggle.desktop" "$DESKTOP_DIR/8bitdo-ptt-toggle.desktop"
run_as_user update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

echo "==> Wiring KDE global shortcut (Meta+F9)..."

KWC=""
if run_as_user which kwriteconfig6 &>/dev/null; then
    KWC="kwriteconfig6"
elif run_as_user which kwriteconfig5 &>/dev/null; then
    KWC="kwriteconfig5"
else
    echo "WARNING: kwriteconfig not found — KDE shortcut not registered. Set it manually in System Settings > Shortcuts."
    exit 0
fi

# Remove Meta+F9 (and Ctrl+F9) from kwin Expose entirely.
run_as_user "$KWC" --file kglobalshortcutsrc --group kwin --key Expose "none,none,Toggle Present Windows (Current desktop)"

# Register the toggle as a KDE global shortcut.
run_as_user "$KWC" --file kglobalshortcutsrc --group "8bitdo-ptt-toggle.desktop" --key "_k_friendly_name" "8BitDo PTT Toggle"
run_as_user "$KWC" --file kglobalshortcutsrc --group "8bitdo-ptt-toggle.desktop" --key "_launch" "Meta+F9,none,Toggle 8BitDo PTT"

# Reload the global shortcut daemon as the real user.
RELOAD_CMD='
    if kquitapp6 kglobalaccel 2>/dev/null; then kglobalaccel6 & disown
    elif kquitapp5 kglobalaccel 2>/dev/null; then kglobalaccel5 & disown
    fi
'
run_as_user bash -c "$RELOAD_CMD" || true

echo ""
echo "Done. Service status:"
systemctl status 8bitdo-ptt --no-pager

echo ""
echo "Toggle hotkey Meta+F9 registered. Test with: /usr/local/bin/8bitdo-ptt-toggle.sh"
