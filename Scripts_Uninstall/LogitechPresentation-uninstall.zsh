#!/bin/zsh
# shellcheck shell=bash

# Uninstall Logitech Presentation

appName="Logitech Presentation"
if [[ $(pgrep -x "$appName") ]]; then
	echo "Closing $appName"
	pkill "$appName"
fi

# Get plugin directory path
app_directory="/Library/Application Support/Logitech.localized/Logitech Presentation.localized"

# Remove installed Mendeley plugins
/bin/rm -rf "$app_directory"
/bin/rm "/Library/Application Support/Logitech.localized/.DS_Store"
# Get rid of Logitech directory if there's nothing else in there (e.g. some other device support app)
[[ $(/bin/ls -A "/Library/Application Support/Logitech.localized") ]] || rm -rf "/Library/Application Support/Logitech.localized"

# Remove the alias
/bin/rm "/Applications/Logitech Presentation" ||:

# Remove the launchagent
/bin/rm "/Library/LaunchAgents/com.logitech.presenter.plist" ||:

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=com.logitech.presentation.pkg && $pkgutilcmd --forget com.logitech.presentation.pkg ||:
