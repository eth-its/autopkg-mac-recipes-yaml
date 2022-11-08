#!/bin/zsh
# shellcheck shell=bash

## Uninstall COMSOL

# COMSOL version
comsol_version="$4"

function silent_app_quit() {
    # silently kill the application.
    appname="COMSOL Multiphysics"
    psname=comsollauncher
    if [[ $(pgrep -ix "$psname") ]]; then
        echo "Closing $appname"
        /usr/bin/osascript -e "quit app \"$appname\""
        sleep 1

        # double-check
        countUp=0
        while [[ $countUp -le 10 ]]; do
            if [[ -z $(pgrep -ix "$psname") ]]; then
                echo "$appname closed."
                break
            else
                let countUp=$countUp+1
                sleep 1
            fi
        done
        if [[ $(pgrep -x "$psname") ]]; then
            echo "$appname failed to quit - killing."
            /usr/bin/pkill "$psname"
        fi
    fi
}

foldername=COMSOL${comsol_version}
if [[ -d "/Applications/$foldername" ]]; then
    app_dir="/Applications/$foldername"
else
    echo "COMSOL $comsol_version not found, nothing to do."
    exit
fi

# quit the app if running
silent_app_quit

# Now remove the app
echo "Removing application: ${app_dir}"

# Manual list of files to remove
rm -rf "$app_dir"
[[ -f "/Library/LaunchDaemons/com.comsol.lmcomsol.plist" ]] && rm -f "/Library/LaunchDaemons/com.comsol.lmcomsol.plist"

# Try to Forget the packages
pkgutilcmd="/usr/sbin/pkgutil"
receipts=$($pkgutilcmd --pkgs=ch.ethz.id.pkg.comsol*)
while read -r receipt; do
    $pkgutilcmd --pkgs="${receipt}" && $pkgutilcmd --forget "${receipt}"
done <<< "${receipts}"        

echo "COMSOL deletion complete"
