#!/bin/sh
# ~/.xinitrc - started by `startx`

# Load system-wide X session scripts (D-Bus, etc.)
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# X resources
[ -f "$HOME/.Xresources" ] && command -v xrdb >/dev/null && xrdb -merge "$HOME/.Xresources"

export TERMINAL=kitty
export PATH="$HOME/.local/bin:$PATH"

# Wallpaper, compositor and status bar
[ -f "$HOME/.local/bin/autostart.sh" ] && . "$HOME/.local/bin/autostart.sh"

exec dwm
