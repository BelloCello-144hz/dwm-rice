# Nord DWM Rice (Arch Linux)

A minimal, Nord-themed [dwm](https://dwm.suckless.org) 6.5 setup:

- **dwm 6.5** with `vanitygaps`, `fibonacci`, `autostart` and `statuscmd` patches
- **Nord** colours everywhere (bar, borders, dmenu, kitty, fish)
- **Status bar** with a clickable app-menu button (󰣇 → dmenu), CPU %, RAM used/total and a clock
- **Layouts:** tile, fibonacci spiral, dwindle, monocle, floating — all with 6 px gaps
- **kitty** terminal + **fish** shell, **JetBrainsMono Nerd Font** (size 14)
- Nord wallpaper from [linuxdotexe/nordic-wallpapers](https://github.com/linuxdotexe/nordic-wallpapers)

```
dwm-rice/
├── README.md
├── install.sh              main Arch install script
├── dwm/
│   ├── config.def.h        Nord dwm config
│   └── patches/
│       ├── vanitygaps.diff
│       ├── fibonacci.diff
│       ├── autostart.diff
│       └── statuscmd.diff
├── kitty/kitty.conf        Nord kitty theme
├── fish/config.fish        Nord prompt + aliases
├── scripts/
│   ├── status.sh           status bar loop (xsetroot)
│   └── autostart.sh        wallpaper, picom, status bar
└── xinitrc                 → ~/.xinitrc
```

---

## 1. Prerequisites

- An Arch Linux (or Arch-based) install with a working network connection
- A normal user account with `sudo` rights (don't run the installer as root)
- `git` to clone this repo (`sudo pacman -S git`)
- No display manager is required — the session starts with `startx` from a TTY

The installer pulls in everything else:

| Package | Purpose |
|---|---|
| `base-devel libx11 libxft libxinerama` | build dwm |
| `xorg-server xorg-xinit xorg-xrandr xorg-xsetroot` | X server, `startx`, monitor setup, status text |
| `feh` | wallpaper |
| `picom` | compositor |
| `kitty` / `fish` | terminal / shell |
| `dmenu` | app launcher |
| `htop` | opened by clicking CPU/RAM on the bar |
| `ttf-jetbrains-mono-nerd fontconfig` | font + icons |

## 2. Install

```sh
git clone <this-repo> ~/dwm-rice     # or copy the folder
cd ~/dwm-rice
chmod +x install.sh
./install.sh
```

What `install.sh` does, in order:

1. `pacman -S --needed` all packages above
2. Downloads `dwm-6.5.tar.gz` from dl.suckless.org
3. Extracts it to `/tmp/dwm-build/`
4. Applies `vanitygaps → fibonacci → autostart → statuscmd` with `patch -p1` (order matters)
5. Copies `dwm/config.def.h` to `config.def.h` **and** `config.h`
6. `make && sudo make install` (installs to `/usr/local/bin/dwm`)
7. Copies `kitty.conf` → `~/.config/kitty/kitty.conf`
8. Copies `config.fish` → `~/.config/fish/config.fish`
9. Copies `scripts/*.sh` → `~/.local/bin/` and makes them executable; links `autostart.sh` into `~/.local/share/dwm/` for the autostart patch
10. Copies `xinitrc` → `~/.xinitrc`
11. Downloads the Nord wallpaper (`arctic-landscape.png`) to `~/Pictures/wallpaper.png`
12. Sets fish as your login shell (`chsh -s $(which fish)`)
13. Prints next steps

Existing kitty/fish/xinitrc files are backed up as `*.bak` before being replaced.

## 3. Start the session

Log out and back in (so fish is your shell), then from a TTY:

```sh
startx
```

## 4. What each file does

### `dwm/config.def.h`
- Nord palette: `#2E3440` bar background, `#D8DEE9` text, `#88C0D0` (frost) selected tag/title and focused border, `#3B4252` unfocused border; border width 2
- Font `JetBrainsMono Nerd Font:size=14`, bar on top
- Gaps: 6 px inner and outer (`gappih/gappiv/gappoh/gappov`)
- Layouts: `[]=` tile, `[@]` spiral, `[\]` dwindle, `[M]` monocle, `><>` floating
- `statuscmds`: block 1 → dmenu, block 2 (CPU) → `kitty -e htop`, block 3 (RAM) → `kitty -e htop` sorted by memory
- Mod key is **Super** (Windows key)

### `dwm/patches/`
All four are unified diffs against the pristine dwm 6.5 tarball and apply in sequence with `patch -p1`. They only touch the dwm sources (`dwm.c`, `dwm.1`, new `fibonacci.c`); the config side of every patch lives in `config.def.h`.

| Patch | Upstream | Change |
|---|---|---|
| `vanitygaps.diff` | [vanitygaps](https://dwm.suckless.org/patches/vanitygaps/) 20200610 | per-monitor inner/outer gaps, `togglegaps`, `incrgaps`…, gap-aware `tile`; rebased for 6.5 |
| `fibonacci.diff` | [fibonacci](https://dwm.suckless.org/patches/fibonacci/) | adds `fibonacci.c` with `spiral` and `dwindle`; this version also honours the vanitygaps gaps (needs vanitygaps applied first) |
| `autostart.diff` | [autostart](https://dwm.suckless.org/patches/autostart/) 20210120 | runs `~/.local/share/dwm/autostart.sh` (and `autostart_blocking.sh`) when dwm starts |
| `statuscmd.diff` | [statuscmd (nosignal)](https://dwm.suckless.org/patches/statuscmd/) | clickable status blocks; rebased for 6.5 |

### `scripts/status.sh`
Updates the root window name once per second with `xsetroot -name`:

```
 󰣇   󰻠 12% | 󰍛 3120/15843M |  Fri 09 Oct 18:42
```

- **CPU %** — two reads of the `cpu` line in `/proc/stat` 0.3 s apart; `100 × (Δtotal − Δidle) / Δtotal`
- **RAM** — `MemTotal − MemAvailable` from `/proc/meminfo`, in MiB
- **Clock** — `date '+%a %d %b %H:%M'`
- Each block starts with a raw byte `\x01`…`\x04`; the statuscmd patch uses these to know what was clicked
- `status.sh --once` prints one line and exits (handy for testing); `STATUS_PLAIN=1` replaces icons with text

### `scripts/autostart.sh`
Sets the wallpaper (`feh --bg-fill ~/Pictures/wallpaper.png`, or solid Nord if the file is missing), starts `picom --daemon` if it isn't running, and (re)starts `status.sh` in the background. It's sourced by `~/.xinitrc` and also run by the dwm autostart patch. Running it twice does no harm.

### `xinitrc`
Runs `/etc/X11/xinit/xinitrc.d/*`, merges `~/.Xresources` if present, adds `~/.local/bin` to `PATH`, sources `autostart.sh`, then `exec dwm`.

### `kitty/kitty.conf`
Full Nord palette (background `#2E3440`, foreground `#D8DEE9`, all 16 ANSI colours), JetBrainsMono Nerd Font 14, `window_padding_width 8`, block cursor, 5000 lines of scrollback, Nord powerline tabs, fish as the shell.

### `fish/config.fish`
- Prompt: `user@host ~/dir (branch*) ❯` in Nord colours (`*` = uncommitted changes, red `❯` after a failed command), time as the right prompt
- Nord syntax-highlighting colours
- `EDITOR=nvim` (or `nano` if nvim is missing), `TERMINAL=kitty`, `~/.local/bin` on `PATH`
- Aliases: `ls`, `ll`, `la`, `grep`, `..`, `...`, `gs`, `gd`, `gl`, `update`, `cleanup`
- Loads your own snippets from `~/.config/fish/local/*.fish` and functions from `~/.config/fish/functions.local/`

## 5. Keybindings

`Mod` = **Super** (Windows key)

| Keys | Action |
|---|---|
| `Mod + Return` | open kitty |
| `Mod + d` | open dmenu (app launcher) |
| `Mod + q` | close focused window |
| `Mod + Shift + q` | quit dwm |
| `Mod + j / k` | focus next / previous window |
| `Mod + h / l` | shrink / grow master area |
| `Mod + i / u` | more / fewer windows in master |
| `Mod + Shift + Return` | swap focused window with master |
| `Mod + Tab` | jump to previous tag |
| `Mod + b` | show / hide bar |
| `Mod + t` | tile layout |
| `Mod + r` | fibonacci spiral layout |
| `Mod + Shift + r` | dwindle layout |
| `Mod + m` | monocle layout |
| `Mod + f` | floating layout |
| `Mod + Space` | switch to previous layout |
| `Mod + Shift + Space` | float / unfloat focused window |
| `Mod + g` | toggle gaps |
| `Mod + Shift + g` | reset gaps to default (6 px) |
| `Mod + = / -` | all gaps bigger / smaller |
| `Mod + Shift + = / -` | outer gaps bigger / smaller |
| `Mod + Ctrl + = / -` | inner gaps bigger / smaller |
| `Mod + Alt + = / -` | inner horizontal gaps |
| `Mod + Alt + Shift + = / -` | inner vertical gaps |
| `Mod + Alt + Ctrl + = / -` | outer horizontal gaps |
| `Mod + Ctrl + Shift + = / -` | outer vertical gaps |
| `Mod + 1…9` | go to tag |
| `Mod + Shift + 1…9` | move window to tag |
| `Mod + Ctrl + 1…9` | also show tag |
| `Mod + Ctrl + Shift + 1…9` | toggle window on tag |
| `Mod + 0` / `Mod + Shift + 0` | show all tags / put window on all tags |
| `Mod + , / .` | focus previous / next monitor |
| `Mod + Shift + , / .` | send window to previous / next monitor |

**Mouse**

| Action | Result |
|---|---|
| Click 󰣇 on the bar | open dmenu |
| Click CPU / RAM on the bar | `htop` in kitty |
| Click a tag | go to that tag (right-click: also show it) |
| Click the layout symbol | previous layout (right-click: monocle) |
| `Mod` + left drag | move window (makes it float) |
| `Mod` + right drag | resize window |
| `Mod` + middle click | float / unfloat |

## 6. Customising

Edit `dwm/config.def.h`, then rebuild:

```sh
cd /tmp/dwm-build/dwm-6.5        # re-run ./install.sh if /tmp was cleared
cp ~/dwm-rice/dwm/config.def.h config.h
make && sudo make install
```

Log out of dwm (`Mod + Shift + q`) and run `startx` again to load the new build.

- **Different wallpaper:** replace `~/Pictures/wallpaper.png` and run `feh --bg-fill ~/Pictures/wallpaper.png`
- **Status bar:** edit `~/.local/bin/status.sh`. Changes take effect after `pkill -f status.sh; ~/.local/bin/status.sh &`
- **Clickable blocks:** add an entry `{ "command", N }` to `statuscmds` and prefix your block with `\x0N` in `status.sh` (N between 1 and 31)

## 7. Troubleshooting

- **Icons show as boxes** — check that `ttf-jetbrains-mono-nerd` is installed and run `fc-cache -fv`; `fc-list | grep JetBrainsMono` should show it.
- **No wallpaper** — the download may have failed; any image at `~/Pictures/wallpaper.png` will work.
- **Status bar shows `dwm-6.5`** — `status.sh` isn't running. Check `xorg-xsetroot` is installed and run `~/.local/bin/status.sh &`.
- **Patch failed** — the patches target the pristine 6.5 tarball, so delete `/tmp/dwm-build` and run `./install.sh` again.
- **Multiple monitors** — dwm draws the status text on the focused monitor; the bar itself appears on all monitors.
