#!/usr/bin/env bash
# install.sh - Nord dwm rice installer for Arch Linux
#
# Run as your normal user (NOT root) from inside the dwm-rice directory:
#   ./install.sh
# sudo is used only for pacman, `make install` and nothing else.

set -euo pipefail

DWM_VERSION="6.5"
DWM_URL="https://dl.suckless.org/dwm/dwm-${DWM_VERSION}.tar.gz"
BUILD_DIR="/tmp/dwm-build"
WALLPAPER_URL="https://raw.githubusercontent.com/linuxdotexe/nordic-wallpapers/master/wallpapers/arctic-landscape.png"
# Patch order matters: fibonacci uses the gap variables added by vanitygaps.
PATCHES=(vanitygaps fibonacci autostart statuscmd)
PACKAGES=(
    base-devel libx11 libxft libxinerama
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot
    feh picom kitty fish dmenu htop curl
    ttf-jetbrains-mono-nerd fontconfig
)

RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf '\033[1;36m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m==> WARNING:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m==> ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- checks
[ "$(id -u)" -ne 0 ] || die "Run this script as your normal user, not root."
command -v pacman >/dev/null || die "pacman not found - this installer targets Arch Linux."
for f in dwm/config.def.h kitty/kitty.conf fish/config.fish scripts/status.sh scripts/autostart.sh xinitrc; do
    [ -f "$RICE_DIR/$f" ] || die "Missing $f - run install.sh from a complete dwm-rice checkout."
done
for p in "${PATCHES[@]}"; do
    [ -f "$RICE_DIR/dwm/patches/$p.diff" ] || die "Missing dwm/patches/$p.diff"
done

# ---------------------------------------------------------- 1. packages
info "Installing packages with pacman"
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# ------------------------------------------------- 2-3. download + extract
info "Downloading dwm ${DWM_VERSION}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
curl -fL --retry 3 -o "$BUILD_DIR/dwm-${DWM_VERSION}.tar.gz" "$DWM_URL"
tar -xzf "$BUILD_DIR/dwm-${DWM_VERSION}.tar.gz" -C "$BUILD_DIR"
SRC="$BUILD_DIR/dwm-${DWM_VERSION}"
cd "$SRC"

# ---------------------------------------------------------- 4. patches
for p in "${PATCHES[@]}"; do
    info "Applying patch: $p"
    patch -p1 --forward < "$RICE_DIR/dwm/patches/$p.diff" \
        || die "Patch $p failed to apply (see *.rej files in $SRC)."
done

# ------------------------------------------------------ 5. config + build
info "Installing Nord config.h"
cp "$RICE_DIR/dwm/config.def.h" config.def.h
cp config.def.h config.h

info "Building and installing dwm"
make clean
make
sudo make install

# ------------------------------------------------------------ 7. kitty
info "Installing kitty config"
mkdir -p "$HOME/.config/kitty"
[ -f "$HOME/.config/kitty/kitty.conf" ] && cp "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf.bak"
cp "$RICE_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# ------------------------------------------------------------- 8. fish
info "Installing fish config"
mkdir -p "$HOME/.config/fish"
[ -f "$HOME/.config/fish/config.fish" ] && cp "$HOME/.config/fish/config.fish" "$HOME/.config/fish/config.fish.bak"
cp "$RICE_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"

# ---------------------------------------------------------- 9. scripts
info "Installing scripts to ~/.local/bin"
mkdir -p "$HOME/.local/bin"
cp "$RICE_DIR"/scripts/*.sh "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/status.sh" "$HOME/.local/bin/autostart.sh"
# Hook for the dwm autostart patch (autostart.sh is idempotent)
mkdir -p "$HOME/.local/share/dwm"
ln -sf "$HOME/.local/bin/autostart.sh" "$HOME/.local/share/dwm/autostart.sh"

# ---------------------------------------------------------- 10. xinitrc
info "Installing ~/.xinitrc"
[ -f "$HOME/.xinitrc" ] && cp "$HOME/.xinitrc" "$HOME/.xinitrc.bak"
cp "$RICE_DIR/xinitrc" "$HOME/.xinitrc"
chmod +x "$HOME/.xinitrc"

# -------------------------------------------------------- 11. wallpaper
info "Downloading Nord wallpaper"
mkdir -p "$HOME/Pictures"
if (cd "$HOME/Pictures" && curl -fLO --retry 3 "$WALLPAPER_URL"); then
    mv -f "$HOME/Pictures/$(basename "$WALLPAPER_URL")" "$HOME/Pictures/wallpaper.png"
else
    warn "Wallpaper download failed - a solid Nord background will be used instead."
fi

# ----------------------------------------------------- 12. default shell
FISH_PATH="$(command -v fish)"
if [ "${SHELL:-}" != "$FISH_PATH" ]; then
    info "Setting fish as default shell"
    grep -qx "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$FISH_PATH" || warn "chsh failed - run 'chsh -s $FISH_PATH' manually."
fi

fc-cache -f >/dev/null 2>&1 || true

# --------------------------------------------------------------- 13. done
cat <<EOF

$(printf '\033[1;36m')Nord dwm rice installed successfully!$(printf '\033[0m')

Next steps:
  1. Log out and back in (so fish becomes your login shell).
  2. From a TTY, run:  startx
  3. Super+Return opens kitty, Super+d (or click the 󰣇 button on the bar) opens dmenu.
  4. Super+Shift+q quits dwm. See README.md for all keybindings.

Rebuild after editing the config:
  cd $SRC && cp $RICE_DIR/dwm/config.def.h config.h && make && sudo make install
EOF
