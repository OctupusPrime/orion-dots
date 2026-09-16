#!/usr/bin/env bash

set -Eeuo pipefail

APP_NAME="orion-dots"
SOURCE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
HYPR_CONFIG="$CONFIG_DIR/hypr/hyprland.lua"

if (( EUID == 0 )); then
    echo "Error: run this installer as your normal user, without sudo." >&2
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "Error: a pacman-based system is required." >&2
    exit 1
fi

if ! command -v Hyprland >/dev/null 2>&1; then
    echo "Error: install and configure Hyprland first." >&2
    exit 1
fi

if [[ ! -s "$HYPR_CONFIG" ]]; then
    echo "Error: expected an existing configuration at $HYPR_CONFIG." >&2
    exit 1
fi

echo "Installing dependencies..."

if ! sudo pacman -S --needed quickshell; then
    echo "Error: dependency installation failed. Fix the pacman error above and rerun the installer." >&2
    exit 1
fi

echo "Installing timezone permission rule..."

sudo install -d -m 0755 /etc/polkit-1/rules.d

sudo tee /etc/polkit-1/rules.d/49-timezone.rules >/dev/null <<'EOF'
/* Allow active local wheel users to change timezone without a password. */
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.timedate1.set-timezone" &&
        subject.isInGroup("wheel") &&
        subject.local &&
        subject.active) {
        return polkit.Result.YES;
    }
});
EOF

sudo chmod 0644 /etc/polkit-1/rules.d/49-timezone.rules

echo "Installing configuration..."

for component in quickshell hypr; do
    parent="$CONFIG_DIR/$component"
    target="$parent/$APP_NAME"

    mkdir -p -- "$parent"
    
    staged="$(mktemp -d "$parent/.${APP_NAME}.XXXXXX")"

    if ! cp -a "$SOURCE/$component/." "$staged/"; then
        rm -rf -- "$staged"
        echo "Error: failed to stage $component configuration." >&2
        exit 1
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        mv --exchange --no-copy -T -- "$staged" "$target"
        rm -rf -- "$staged"
    else
        mv --no-copy -T -- "$staged" "$target"
    fi
done

# Import Orion's Lua configuration once.
IMPORT_LINE="require(\"$APP_NAME/main\")"

if ! grep -Fxq -- "$IMPORT_LINE" "$HYPR_CONFIG"; then
    printf '\n%s\n' "$IMPORT_LINE" >> "$HYPR_CONFIG"
fi

echo "Installation complete. Reboot or log out and back in for all changes to take effect."