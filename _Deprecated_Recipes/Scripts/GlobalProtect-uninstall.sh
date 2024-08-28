#!/bin/bash

#######################################################################
#
# Remove GlobalProtect Script for Jamf Pro
#
#######################################################################

echo "Running GlobalProtect uninstaller script"

if "/Applications/GlobalProtect.app/Contents/Resources/uninstall_gp.sh" ; then
    echo "GlobalProtect uninstaller script succeeded"
else
    echo "GlobalProtect uninstaller script failed"
    exit 1
fi

# Forget packages
echo "Forgetting package"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=com.paloaltonetworks.globalprotect.pkg && $pkgutilcmd --forget com.paloaltonetworks.globalprotect.pkg

echo "GlobalProtect deletion complete"
