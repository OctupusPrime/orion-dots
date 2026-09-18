#!/bin/bash
set -eu

# --- Usage ---
# ./wallpaper.sh IMAGE
# ./wallpaper.sh LIGHT_IMAGE DARK_IMAGE

[ "$#" -gt 0 ] || exit 0
[ "$#" -le 2 ] || {
    echo "Usage: $0 [IMAGE | LIGHT_IMAGE DARK_IMAGE]" >&2
    exit 1
}

CURRENT_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)
BACKGROUND_SYMLINK="$HOME/.local/state/orion-dots/wallpaper"

# Validate every supplied file before creating the symlink.
for wallpaper do
    if [ ! -f "$wallpaper" ] || [ ! -r "$wallpaper" ]; then
        echo "Invalid wallpaper file: $wallpaper" >&2
        exit 1
    fi
done

wallpaper=$1

if [ "$#" -eq 2 ]; then
    if [ "$CURRENT_SCHEME" = "'prefer-dark'" ]; then
        wallpaper=$2
    fi
fi

mkdir -p -- "${BACKGROUND_SYMLINK%/*}"
ln -sfnT -- "$wallpaper" "$BACKGROUND_SYMLINK"

hyprctl monitors |
while IFS=' ' read -r label monitor rest; do
    [ "$label" = "Monitor" ] || continue
    hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
done