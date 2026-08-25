#!/bin/bash
# Save tmux sessions, close all apps except tmux, then reboot or poweroff.
# Usage: shutdown-helper.sh [reboot|poweroff]

ACTION="${1:-poweroff}"

# 1. Save tmux sessions via resurrect
tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh 2>/dev/null

# 2. Close all Hyprland windows except tmux
~/.config/hypr/scripts/close-all-except-tmux.sh

# 3. Wait a moment for windows to close
sleep 1

# 4. Reboot or poweroff
if [ "$ACTION" = "reboot" ]; then
    systemctl reboot
else
    systemctl poweroff
fi
