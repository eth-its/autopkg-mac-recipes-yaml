#!/bin/bash

#######################################################################
#
# Uninstall Adobe Flash Player
#
#######################################################################

munki_path="/usr/local/munki"

# Check if removepackages has been installed
if [[ ! -f "${munki_path}/removepackages" ]]; then
    echo "${munki_path}/removepackages binary not installed!"
    /usr/local/bin/jamf policy -event ETHPkgUninstallerTool-install
fi

appName="Flash Player"

if [[ $(pgrep -x "$appName") ]]; then
	echo "Closing $appName"
	pkill "$appName"
fi

# Now use munki's removepackages tool to remove all files associated with the installed pkg.
# This uses the remaining parameters which should all be package IDs
# which can be obtained using the command `pkgutil --pkgs`

echo "Removing application: ${appName}"

fm_receipts="com.adobe.pkg.FlashPlayer
ch.ethz.mac.pkg.Adobe_Flash_Player.ML"

# Loop through the remaining parameters
while read -r receipt; do
    ${munki_path}/removepackages -f ${receipt}
done <<< "${fm_receipts}"

# We also need to remove the plugin, which was installed using a postinstall script built into the package
# See https://groups.google.com/forum/#!topic/munki-dev/F5SYd4Oyn_c
/bin/rm -rf "/Library/Internet Plug-Ins/Flash Player.plugin"

echo "${appName} removal complete!"
