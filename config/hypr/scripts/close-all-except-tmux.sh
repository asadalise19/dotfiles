#!/bin/bash
# Close all Hyprland windows except terminal windows running tmux.

hyprctl clients -j | jq -r '.[] | "\(.address)|\(.pid)|\(.class)"' | while IFS='|' read -r addr pid class; do
    # Check if tmux exists in this window's process subtree
    if pgrep -P "$pid" tmux >/dev/null 2>&1 || \
       ps --ppid "$pid" -o comm= 2>/dev/null | grep -q tmux || \
       pstree -p "$pid" 2>/dev/null | grep -q tmux; then
        continue
    fi
    hyprctl dispatch closewindow "address:$addr" >/dev/null 2>&1
done
