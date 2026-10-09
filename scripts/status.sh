#!/usr/bin/env bash
# status.sh - dwm status bar: app-menu button | CPU% | RAM used/total | clock
#
# Each block is prefixed by a raw control byte (\x01, \x02, ...). The
# statuscmd patch uses these bytes to know which block was clicked and runs
# the matching command from `statuscmds` in config.h:
#   \x01 app-menu button -> dmenu
#   \x02 CPU             -> htop
#   \x03 RAM             -> htop (sorted by memory)
#   \x04 clock           -> (no action)
#
# Usage: status.sh          run forever, updating the bar every ~1s
#        status.sh --once   print one status line to stdout and exit

# Nerd Font icons, with plain-text fallbacks (STATUS_PLAIN=1 status.sh)
if [ "${STATUS_PLAIN:-0}" = "1" ]; then
    ICON_MENU="[menu]"; ICON_CPU="CPU"; ICON_RAM="RAM"; ICON_CLOCK=""
else
    ICON_MENU="󰣇"; ICON_CPU="󰻠"; ICON_RAM="󰍛"; ICON_CLOCK=""
fi

# Print "total idle" jiffies from the aggregate cpu line of /proc/stat
read_cpu() {
    awk '/^cpu /{ idle = $5 + $6; total = 0; for (i = 2; i <= NF; i++) total += $i; printf "%.0f %.0f\n", total, idle; exit }' /proc/stat
}

cpu_usage() {
    local t1 i1 t2 i2 dt di
    read -r t1 i1 < <(read_cpu)
    sleep 0.3
    read -r t2 i2 < <(read_cpu)
    dt=$((t2 - t1))
    di=$((i2 - i1))
    if [ "$dt" -le 0 ]; then
        echo 0
    else
        echo $(( (100 * (dt - di) + dt / 2) / dt ))
    fi
}

# Print "USED/TOTAL" in MiB, used = MemTotal - MemAvailable
ram_usage() {
    awk '/^MemTotal:/{ t = $2 } /^MemAvailable:/{ a = $2 }
         END { printf "%d/%d", (t - a) / 1024, t / 1024 }' /proc/meminfo
}

status_line() {
    local cpu ram clock
    cpu=$(cpu_usage)
    ram=$(ram_usage)
    clock=$(date '+%a %d %b %H:%M')
    printf '\x01  %s  \x02 %s %s%% |\x03 %s %sM |\x04 %s %s ' \
        "$ICON_MENU" "$ICON_CPU" "$cpu" "$ICON_RAM" "$ram" "$ICON_CLOCK" "$clock"
}

if [ "${1:-}" = "--once" ]; then
    status_line
    echo
    exit 0
fi

if ! command -v xsetroot >/dev/null 2>&1; then
    echo "status.sh: xsetroot not found (install xorg-xsetroot)" >&2
    exit 1
fi

while true; do
    xsetroot -name "$(status_line)"
    sleep 1
done
