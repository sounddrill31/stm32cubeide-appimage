#!/bin/bash
set -euo pipefail # Exit on error, unset variable, or pipe failure

# ---
# Simplified, non-interactive installer for STM32CubeIDE.
# Prepares a directory structure for packaging (e.g., AppImage).
#
# Usage:
# ./ci_install.sh
# ./ci_install.sh --output-prefix /path/to/YourAppDir
# ---

# --- Configuration ---
APPDIR_PREFIX="AppDir" # Default output prefix

# --- Argument Parsing ---
while [[ $# -gt 0 ]]; do
  case $1 in
    --output-prefix)
      APPDIR_PREFIX="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# --- Path Setup ---
thisdir=$(readlink -f "$(dirname "$0")")

# Read the installation path suffix from the file (e.g., /opt/st/stm32cubeide_1.19.0)
default_install_suffix=$(cat "$thisdir/default_install_path.txt")

# Construct the final installation path by joining the prefix and the suffix.
# The sed command removes a potential leading '/' to ensure path joining works correctly.
final_installdir="$APPDIR_PREFIX/$(echo "$default_install_suffix" | sed 's|^/||')"

echo "Preparing installation in: $final_installdir"

# --- Main Installation ---
# Ensure all our helper scripts are executable
chmod +x "$thisdir"/*.sh

echo "Creating target directory..."
mkdir -p "$final_installdir"

echo "Extracting STM32CubeIDE application files..."
tar zxf "$thisdir"/st-stm32cubeide*.tar.gz -C "$final_installdir"

echo "Running privileged installation tasks..."
sudo "$thisdir/ci_install_as_root.sh" "$APPDIR_PREFIX" "$final_installdir"

echo "--------------------------------------------------------"
echo "STM32CubeIDE installation structure prepared successfully in '$APPDIR_PREFIX'"
echo "--------------------------------------------------------"
