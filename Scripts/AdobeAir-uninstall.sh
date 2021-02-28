#!/bin/bash

# Adobe AIR uninstaller

installer="/Applications/Utilities/Adobe AIR Uninstaller.app"
framework="/Library/Frameworks/Adobe AIR.framework"

# run the official uninstaller (works for recent versions)
if [[ -d "$installer" ]]; then
    echo "Uninstalling Adobe AIR"
    "$installer/Contents/MacOS/Adobe AIR Installer" -uninstall ||:
else
    echo "Uninstaller not present"
fi

# also do some manual deleting
[[ -d "$installer" ]] && rm -Rf "$installer"
[[ -d "$framework" ]] && rm -Rf "$framework"

if [[ -d "$framework" ]]; then
    echo "Adobe AIR failed to uninstall"
    exit 1
fi

# Forget packages
echo "Forgetting package"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=com.adobe.pkg.AIR && $pkgutilcmd --forget com.adobe.pkg.AIR
