#!/bin/bash

set -e

GODOT_URL=$(curl -s https://api.github.com/repos/godotengine/godot/releases/latest | grep -Eo 'https://github.com/godotengine/godot/releases/download/.*/Godot_v.*_linux.x86_64.zip' | head -n 1)
GODOT_DIR="/opt/godot"
GODOT_EXEC="$GODOT_DIR/Godot"
ICON_URL="https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg"
ICON_PATH="$GODOT_DIR/icon.png"
DESKTOP_ENTRY="$HOME/.local/share/applications/godot.desktop"
DOWNLOAD_DIR="/tmp"

if ! command -v curl &> /dev/null || ! command -v wget &> /dev/null; then
    echo "Errorr : curl and wget are required to run this script."
    exit 1
fi

sudo mkdir -p "$GODOT_DIR"

echo "Downloadig Godot from : $GODOT_URL"
wget -q --show-progress -O $DOWNLOAD_DIR/Godot.zip "$GODOT_URL"

unzip -o $DOWNLOAD_DIR/Godot.zip -d $DOWNLOAD_DIR/
sudo mv $DOWNLOAD_DIR/Godot_v*_linux.x86_64 "$GODOT_EXEC"
sudo chmod +x "$GODOT_EXEC"

echo "Downloading icon..."
wget -q -O "$DOWNLOAD_DIR/godot_icon.png" "$ICON_URL"
echo "Moving icon near the executable"
sudo mv "$DOWNLOAD_DIR/godot_icon.png" "$ICON_PATH"

echo "Create shortcut..."
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

echo "Installation done. Start Godot from the applications menu !"
