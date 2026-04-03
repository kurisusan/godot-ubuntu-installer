#!/bin/bash

set -euo pipefail

GODOT_DIR="/opt/godot"
GODOT_EXEC="$GODOT_DIR/Godot"
ICON_URL="https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg"
ICON_PATH="$GODOT_DIR/icon.svg"
DESKTOP_ENTRY="$HOME/.local/share/applications/godot.desktop"
DOWNLOAD_DIR="/tmp/godot_install"

for cmd in curl wget unzip; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: '$cmd' is required to run this script."
        exit 1
    fi
done

GODOT_URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep -Eo 'https://github.com/godotengine/godot/releases/download/.*/Godot_v.*_linux.x86_64.zip' | head -n 1)

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

echo "Downloading Godot from: $GODOT_URL"
wget -q --show-progress -O "$DOWNLOAD_DIR/Godot.zip" "$GODOT_URL"

unzip -o "$DOWNLOAD_DIR/Godot.zip" -d "$DOWNLOAD_DIR/"
sudo mv "$DOWNLOAD_DIR"/Godot_v*_linux.x86_64 "$GODOT_EXEC"
sudo chmod +x "$GODOT_EXEC"

echo "Downloading icon..."
wget -q -O "$DOWNLOAD_DIR/godot_icon.svg" "$ICON_URL"
echo "Moving icon near the executable"
sudo mv "$DOWNLOAD_DIR/godot_icon.svg" "$ICON_PATH"

echo "Creating shortcut..."
mkdir -p "$(dirname "$DESKTOP_ENTRY")"
cat <<EOF > "$DESKTOP_ENTRY"
[Desktop Entry]
Name=Godot
Exec=$GODOT_EXEC
Icon=$ICON_PATH
Type=Application
Categories=Development;
Terminal=false
EOF

chmod +x "$DESKTOP_ENTRY"
update-desktop-database ~/.local/share/applications

echo "Installation done. Start Godot from the applications menu!"
