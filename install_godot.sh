#!/bin/bash

set -euo pipefail

GODOT_DIR="/opt/godot"
GODOT_EXEC="$GODOT_DIR/Godot"
GODOT_WRAPPER="$GODOT_DIR/godot-launcher"
ICON_URL="https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg"
ICON_PATH="$GODOT_DIR/icon.svg"
DESKTOP_ENTRY="$HOME/.local/share/applications/godot.desktop"
DOWNLOAD_DIR="/tmp/godot_install"

if [ "${1:-}" = "--remove" ]; then
    echo "Removing Godot..."
    sudo rm -rf "$GODOT_DIR"
    sudo rm -f /usr/local/bin/godot
    rm -f "$DESKTOP_ENTRY"
    update-desktop-database ~/.local/share/applications
    echo "Godot has been removed."
    exit 0
fi

EDITION=""
if [ "${1:-}" = "--classic" ]; then
    EDITION="classic"
elif [ "${1:-}" = "--mono" ]; then
    EDITION="mono"
fi

if [ -z "$EDITION" ]; then
    echo "Which edition of Godot do you want to install?"
    echo "  1) Godot (classic - GDScript)"
    echo "  2) Godot Mono (C# support)"
    read -rp "Enter your choice [1/2]: " choice
    case "$choice" in
        1) EDITION="classic" ;;
        2) EDITION="mono" ;;
        *) echo "Error: invalid choice."; exit 1 ;;
    esac
fi

for cmd in curl wget unzip; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: '$cmd' is required to run this script."
        exit 1
    fi
done

if [ "$EDITION" = "mono" ]; then
    GODOT_URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep -Eo 'https://github.com/godotengine/godot/releases/download/.*/Godot_v.*_mono_linux_x86_64.zip' | head -n 1)
else
    GODOT_URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep -Eo 'https://github.com/godotengine/godot/releases/download/.*/Godot_v.*_linux.x86_64.zip' | head -n 1)
fi

if [ -z "$GODOT_URL" ]; then
    echo "Error: could not find the latest Godot download URL."
    exit 1
fi

mkdir -p "$DOWNLOAD_DIR"
sudo mkdir -p "$GODOT_DIR"

cleanup() {
    rm -rf "$DOWNLOAD_DIR"
}
trap cleanup EXIT

echo "Downloading Godot ($EDITION) from: $GODOT_URL"
wget -q --show-progress -O "$DOWNLOAD_DIR/Godot.zip" "$GODOT_URL"

unzip -o "$DOWNLOAD_DIR/Godot.zip" -d "$DOWNLOAD_DIR/"

if [ "$EDITION" = "mono" ]; then
    MONO_DIR=$(find "$DOWNLOAD_DIR" -maxdepth 1 -type d -name "Godot_v*_mono_linux_x86_64" | head -n 1)
    sudo cp -r "$MONO_DIR"/. "$GODOT_DIR/"
    MONO_BIN=$(find "$GODOT_DIR" -maxdepth 1 -type f -name "Godot_v*" | head -n 1)
    sudo mv "$MONO_BIN" "$GODOT_EXEC"
else
    sudo mv "$DOWNLOAD_DIR"/Godot_v*_linux.x86_64 "$GODOT_EXEC"
fi
sudo chmod +x "$GODOT_EXEC"

echo "Downloading icon..."
wget -q -O "$DOWNLOAD_DIR/godot_icon.svg" "$ICON_URL"
echo "Moving icon near the executable"
sudo mv "$DOWNLOAD_DIR/godot_icon.svg" "$ICON_PATH"

echo "Creating launcher wrapper (auto-detects Wayland)..."
sudo tee "$GODOT_WRAPPER" > /dev/null <<'WRAPPER'
#!/bin/bash
ARGS=()
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    ARGS+=(--display-driver wayland)
fi
exec /opt/godot/Godot "$@" "${ARGS[@]}"
WRAPPER
sudo chmod +x "$GODOT_WRAPPER"

echo "Adding Godot to PATH..."
sudo ln -sf "$GODOT_WRAPPER" /usr/local/bin/godot

echo "Creating shortcut..."
mkdir -p "$(dirname "$DESKTOP_ENTRY")"
cat <<EOF > "$DESKTOP_ENTRY"
[Desktop Entry]
Name=Godot
Exec=$GODOT_WRAPPER
Icon=$ICON_PATH
Type=Application
Categories=Development;
Terminal=false
StartupWMClass=Godot
EOF

chmod +x "$DESKTOP_ENTRY"
update-desktop-database ~/.local/share/applications

echo "Installation done. Start Godot from the applications menu!"
