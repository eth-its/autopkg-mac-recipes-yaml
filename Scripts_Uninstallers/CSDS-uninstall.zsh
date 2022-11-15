#!/bin/zsh
# shellcheck shell=bash

#######################################################################
#
# Remove CSDS Script for Jamf Pro
#
#######################################################################

echo "Running CSDS uninstaller script"

# run the installer if present
uninstaller="/Applications/CSDS/CSD_%MAJOR_VERSION%/uninstall.app/Contents/MacOS/osx-x86_64"
if [[ -f "$uninstaller" ]]; then
    if "$uninstaller" --mode unattended; then
        echo "Uninstaller ran successfully"
    else
        echo "An error occurred during uninstallation. Proceeding to delete folder anyway."
    fi
fi

csds_folder="/Applications/CSDS"

# remove files
if [[ -d "$csds_folder" ]]; then
    if /bin/rm -rf "$csds_folder/"*_%MAJOR_VERSION%; then
        echo "Removed $csds_folder/*_%MAJOR_VERSION%"
    else
        echo "ERROR: failed to remove $csds_folder/*_%MAJOR_VERSION%"
        exit 1
    fi
fi

# remove CSDS folder if empty
if find "$csds_folder" -mindepth 1 -maxdepth 1 | read; then
    echo "$csds_folder not empty so not deleting"
else
    echo "$csds_folder empty so deleting"
    if /bin/rm -rf "$csds_folder"; then
        echo "Removed $csds_folder"
    else
        echo "ERROR: failed to remove $csds_folder"
    fi
fi

# Forget package
echo "Forgetting package receipt"
pkgutilcmd="/usr/sbin/pkgutil"
receipt="ch.ethz.id.pkg.CSDS%MAJOR_VERSION%"

$pkgutilcmd --pkgs="$receipt" && $pkgutilcmd --forget "$receipt"

echo "CSDS %MAJOR_VERSION% deletion complete"
