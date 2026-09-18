#!/bin/bash

# --- Usage ---
# ./change-color-theme.sh light [wallpaper-path]
# ./change-color-theme.sh dark [wallpaper-path]
# An omitted or empty wallpaper path leaves the wallpaper unchanged.

MODE=${1:-}
BACKGROUND=${2:-}

if [[ "$MODE" != "light" && "$MODE" != "dark" ]]; then
    echo "Error: Argument must be 'light' or 'dark'"
    exit 1
fi

# Check if already in desired mode
CURRENT_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)

# GTK Theme
GTK_LIGHT="Breeze"
GTK_DARK="Breeze-Dark"

# QT Theme
QT_STYLE="Breeze"
QT_LIGHT="/usr/share/color-schemes/BreezeLight.colors"
QT_DARK="/usr/share/color-schemes/BreezeDark.colors"

# Background image
BACKGROUND_SYMLINK="$HOME/.local/state/orion-dots/wallpaper"

# Function to update qt5ct and qt6ct config files
update_qt_config() {
    local SCHEME_PATH="$1"
    
    for CONF in "$HOME/.config/qt5ct/qt5ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"; do
        if [ -f "$CONF" ]; then
            sed -i "s|^color_scheme_path=.*|color_scheme_path=$SCHEME_PATH|" "$CONF"
            sed -i "s|^custom_palette=.*|custom_palette=true|" "$CONF"
            sed -i "s|^style=.*|style=$QT_STYLE|" "$CONF"
        fi
    done
}

if [[ "$CURRENT_SCHEME" == "'prefer-$MODE'" ]]; then
    echo "Already in $MODE mode."
elif [ "$MODE" == "light" ]; then
    echo "Switching to Light Mode..."

    # --- GTK ---
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_LIGHT"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'

    # --- QT ---
    update_qt_config "$QT_LIGHT"

elif [ "$MODE" == "dark" ]; then
    echo "Switching to Dark Mode..."

    # --- GTK ---
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_DARK"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

    # --- QT ---
    update_qt_config "$QT_DARK"

fi

# Apply wallpaper even when the theme is already active (e.g. settings reload).
if [[ -n "$BACKGROUND" ]]; then
    if [[ ! -f "$BACKGROUND" || ! -r "$BACKGROUND" ]]; then
        echo "Warning: wallpaper is not a readable file: $BACKGROUND" >&2
    elif [[ -e "$BACKGROUND_SYMLINK" && ! -L "$BACKGROUND_SYMLINK" ]]; then
        echo "Warning: refusing to replace a non-symlink: $BACKGROUND_SYMLINK" >&2
    elif hyprctl hyprpaper wallpaper ",${BACKGROUND},cover"; then
        mkdir -p -- "${BACKGROUND_SYMLINK%/*}" &&
            ln -sfnT -- "$BACKGROUND" "$BACKGROUND_SYMLINK"
    else
        echo "Warning: failed to apply wallpaper: $BACKGROUND" >&2
    fi
fi

echo "Theme switch completed."
