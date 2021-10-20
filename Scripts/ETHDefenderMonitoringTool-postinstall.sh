#!/bin/bash
## ETH Defender Monitoring Tool Version EA

install_dir="/Library/Application Support/ETHZ/Defender"

# create version file
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkg-info-plist ch.ethz.defender-monitoring.pkg > "$install_dir/pkginfo.plist"

version=$(/usr/libexec/PlistBuddy -c "Print :pkg-version" "$install_dir/pkginfo.plist")

echo "ETH Defender Monitoring Tool v.$version installed"
