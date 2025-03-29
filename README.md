# Godot Auto-Installer for Ubuntu

This script automates the installation of the latest version of Godot on Ubuntu.  
It downloads the latest release, moves it to `/opt/godot/`, adds an application shortcut, and sets up an icon.

## Features

- Automatically fetches the latest Godot version.
- Moves the executable to `/opt/godot/` for easy access.
- Creates a `.desktop` shortcut for the application menu.
- Downloads an official Godot icon.
- Ensures everything is executable and properly set up.

## Installation & Usage

1. Clone this repository:

```bash
git clone https://github.com/your-username/godot-installer.git
cd godot-installer
```

2. Run the script

```bash
chmod +x install_godot.sh
./install_godot.sh
```

3. Once installed, search for "Godot" in your application menu and pin it for quick access.

## Notes

- This script requires curl, wget, and unzip. If they are missing, install them with:

```bash
sudo apt install curl wget unzip -y
```

- The script installs the standard Linux 64-bit version (x11.64).
- To update Godot later, just rerun the script.

## Uninstallation

To remove Godot and the shortcut:

```bash
sudo rm -rf /opt/godot
rm ~/.local/share/applications/godot.desktop
```

---

Enjoy coding with Godot! 🎮🚀
