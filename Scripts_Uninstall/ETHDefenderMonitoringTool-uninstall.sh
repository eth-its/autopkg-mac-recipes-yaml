#!/bin/bash
## ETH Defender Monitoring Tool uninstallation

install_dir="/Library/Application Support/ETHZ/Defender"

# remove files
if [[ -d "$install_dir" ]]; then
    rm -rf "${install_dir}" ||:
fi

# unload the LaunchDaemon
/bin/launchctl unload -w /Library/LaunchDaemons/ch.ethz.defender-monitoring.plist

# remove the LaunchDaemon
rm -f /Library/LaunchDaemons/ch.ethz.defender-monitoring.plist

# forget the package receipt
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
receipt="ch.ethz.defender-monitoring.pkg"

$pkgutilcmd --pkgs="${receipt}" && $pkgutilcmd --forget "${receipt}"
