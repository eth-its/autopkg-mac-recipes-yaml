#!/bin/bash

#######################################################################
#
# Wireshark Uninstaller Script for Jamf Pro
#
#######################################################################

currentUser="$3"

#run pkgs to uninstall tools, that are shipped inside the application itself
echo "Running bundled uninstallers for tools"
/usr/sbin/installer -pkg '/Applications/Wireshark.app/Contents/Resources/Extras/Remove Wireshark from the system path.pkg' -target /
/usr/sbin/installer -pkg '/Applications/Wireshark.app/Contents/Resources/Extras/Uninstall ChmodBPF.pkg' -target /

# Forget installed packages if receipts exist
echo "Checking for installed Nudge package receipts"
for pkgid in org.wireshark.Wireshark.pkg; do
    if ls "/private/var/db/receipts/${pkgid}"*.bom &>/dev/null; then
        echo "Forgetting package: $pkgid"
        /usr/sbin/pkgutil --forget "$pkgid" 2>/dev/null || echo "Package forget failed for $pkgid"
    fi
done


# Remove the Application
/bin/rm -Rf /Applications/Wireshark.app
echo "Wireshark.app has been removed"
