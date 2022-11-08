#!/bin/zsh
# shellcheck shell=bash

# Uninstall swiftDialog

appName="Dialog"
if [[ $(pgrep -x "$appName") ]]; then
    echo "quit: " > /var/tmp/dialog.log
	echo "Closing $appName"
	pkill "$appName"
fi

# Get plugin directory path
app_directory="/Library/Application Support/Dialog"
bin_shortcut="/usr/local/bin/dialog"

/bin/rm -rf "$app_directory" 
/bin/rm -f "$bin_shortcut" /var/tmp/dialog.*

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=au.csiro.dialogcli && $pkgutilcmd --forget au.csiro.dialogcli ||:
