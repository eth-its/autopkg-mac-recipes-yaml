#!/bin/zsh
# shellcheck shell=bash

#######################################################################
#
# Remove CSDS Script for Jamf Pro
#
#######################################################################

echo "Running CSDS uninstaller script"

# run the installer if present
uninstaller="/Applications/CSDS %MAJOR_VERSION%/CSD_%MAJOR_VERSION%/uninstall.app/Contents/MacOS/osx-x86_64"
if [[ -f "$uninstaller" ]]; then
    if "$uninstaller" --mode unattended; then
        echo "Uninstaller ran successfully"
    else
        echo "An error occurred during uninstallation. Proceeding to delete folder anyway."
    fi
fi

csds_folder="/Applications/CSDS %MAJOR_VERSION%"

# remove files
if [[ -d "$csds_folder" ]]; then
    if rm -rf "$csds_folder"; then
        echo "Removed $csds_folder"
    else
        echo "ERROR: failed to remove $csds_folder"
        exit 1
    fi
fi

# Forget package
echo "Forgetting package receipt"
pkgutilcmd="/usr/sbin/pkgutil"
receipt="ch.ethz.id.pkg.CSDS"

$pkgutilcmd --pkgs="$receipt" && $pkgutilcmd --forget "$receipt"

echo "CSDS deletion complete"
