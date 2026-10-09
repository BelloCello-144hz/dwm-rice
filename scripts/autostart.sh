#!/bin/sh
# autostart.sh - session startup for the Nord dwm rice.
#
# Sourced by ~/.xinitrc before dwm starts. It is also linked to
# ~/.local/share/dwm/autostart.sh so the dwm autostart patch can run it;
# every step is idempotent, so running it twice is harmless.
# NOTE: never call `exit` here - this file is sourced by ~/.xinitrc.

WALLPAPER="$HOME/Pictures/wallpaper.png"
BIN="$HOME/.local/bin"

# Wallpaper (fall back to a solid Nord background if the image is missing)
if [ -f "$WALLPAPER" ]; then
    feh --no-fehbg --bg-fill "$WALLPAPER" &
else
    xsetroot -solid "#2E3440"
fi

# Compositor
if command -v picom >/dev/null 2>&1 && ! pgrep -x picom >/dev/null 2>&1; then
    picom --daemon
fi

# Status bar loop (restart it so a re-run never leaves duplicates)
pkill -f "$BIN/status.sh" >/dev/null 2>&1
"$BIN/status.sh" >/dev/null 2>&1 &
