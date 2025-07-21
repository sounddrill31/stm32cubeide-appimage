#!/bin/bash
set -euo pipefail

# ---
# Privileged task script for the CI installer.
# This script is called with sudo by the main installer.
# It executes component installers into the AppDir and stages udev rules.
# ---

# --- Argument Handling ---
if [ "$#" -ne 2 ]; then
    echo "Usage: sudo $0 <AppDir_Prefix> <Final_Install_Dir>" >&2
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root." >&2
   exit 1
fi

APPDIR_PREFIX="$1"
INSTALL_DIR="$2"
thisdir=$(readlink -f "$(dirname "$0")")

echo "Running as root..."

# --- 1. Stage Desktop Shortcut ---
# Read the target location for the desktop file (e.g., /usr/share/applications/st-stm32cubeide.desktop)
desktop_file_suffix=$(cat "$thisdir/desktop_file_location.txt")
# Create the .desktop file inside the AppDir prefix, not on the host system
final_desktop_file="$APPDIR_PREFIX/$(echo "$desktop_file_suffix" | sed 's|^/||')"

echo "Staging desktop file at: $final_desktop_file"
mkdir -p "$(dirname "$final_desktop_file")"
"$thisdir/desktop_shortcut.sh" "$(cat "$thisdir/version.txt")" "$INSTALL_DIR" "$final_desktop_file"
chmod a+r "$final_desktop_file"


# --- 2. Install Non-Udev Components (e.g., ST-Link Server) ---
echo "Installing ST-Link Server component into the AppDir structure..."

# Find the ST-Link server installer script
server_installer=$(find "$thisdir" -name "st-stlink-server.*.install.sh")

if [ -n "$server_installer" ]; then
    # Use DESTDIR to redirect the installation into our AppDir prefix.
    # This ensures files that would go to /usr/bin go to AppDir/usr/bin instead.
    # The installer script itself is executed.
    export LICENSE_ALREADY_ACCEPTED=1
    DESTDIR="$APPDIR_PREFIX" sh "$server_installer"
    echo "ST-Link Server installation complete."
else
    echo "Warning: ST-Link Server installer not found." >&2
fi


# --- 3. Stage Udev Rule Installers ---
# Instead of installing to the host system, move the udev installers to a
# dedicated folder inside the AppDir for later processing by the AppImage tool.
scripts_dir="$APPDIR_PREFIX/opt/st-scripts"
echo "Moving udev rule installers to: $scripts_dir"
mkdir -p "$scripts_dir"

# Move only the udev rules installers to the staging directory
mv "$thisdir"/st-stlink-udev-rules-*.sh \
   "$thisdir"/segger-jlink-udev-rules-*.sh \
   "$scripts_dir/"

echo "Privileged tasks completed."