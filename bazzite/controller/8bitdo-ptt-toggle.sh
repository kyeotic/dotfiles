#!/usr/bin/env bash
# Toggle 8bitdo-ptt systemd service on/off. Intended for a KDE global shortcut.
set -euo pipefail

SERVICE=8bitdo-ptt

if systemctl is-active --quiet "$SERVICE"; then
    sudo systemctl stop "$SERVICE"
    notify-send -i input-gaming -t 3000 "8BitDo PTT" "Pass-through disabled (service stopped)"
else
    sudo systemctl start "$SERVICE"
    notify-send -i input-gaming -t 3000 "8BitDo PTT" "Pass-through enabled (service started)"
fi
