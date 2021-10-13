#!/bin/bash
## ETH Defender Monitoring Tool Version EA

install_dir="/Library/Application Support/ETHZ/Defender"

# create version file if not present
pkgutilcmd="/usr/sbin/pkgutil"
if [[ ! -f "$install_dir/pkginfo.plist" ]]; then
    $pkgutilcmd --pkg-info-plist ch.ethz.defender-monitoring.pkg > "$install_dir/pkginfo.plist"
fi

version=$(/usr/libexec/PlistBuddy -c "Print :pkg-version" "$install_dir/pkginfo.plist")

echo "<result>$version</result>"

exit 0