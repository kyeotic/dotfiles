#!/usr/bin/env bash
# Installs the 8BitDo PTT pass-through script and systemd service.
# Idempotent: safe to re-run after any change to the .py or .service file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing 8bitdo-ptt..."

install -m 755 "$SCRIPT_DIR/8bitdo-ptt.py" /usr/local/bin/8bitdo-ptt.py
install -m 644 "$SCRIPT_DIR/8bitdo-ptt.service" /etc/systemd/system/8bitdo-ptt.service

systemctl daemon-reload
systemctl enable 8bitdo-ptt
systemctl restart 8bitdo-ptt

echo "Done. Status:"
systemctl status 8bitdo-ptt --no-pager
