#!/bin/zsh
# shellcheck shell=bash

## Uninstall PopChar

function silent_app_quit() {
    # silently kill the application.
    appname="PopChar"
    if [[ $(pgrep -ix "$appname") ]]; then
        echo "Closing $appname"
        /usr/bin/osascript -e "quit app \"$appname\""
        sleep 1

        # double-check
        countUp=0
        while [[ $countUp -le 10 ]]; do
            if [[ -z $(pgrep -ix "$appname") ]]; then
                echo "$appname closed."
                break
            else
                let countUp=$countUp+1
                sleep 1
            fi
        done
        if [[ $(pgrep -x "$appname") ]]; then
            echo "$appname failed to quit - killing."
            /usr/bin/pkill "$appname"
        fi
    fi
}

# PopChar is installed in a directory along with the sitekey file, so we delete the entire directory
if [[ -d "/Applications/$appname" ]]; then
    app_dir="/Applications/$appname"
else
    echo "PopChar not found, nothing to do."
    exit
fi

# quit the app if running
silent_app_quit

# Now remove the app
echo "Removing application: ${app_dir}"

# Try to Forget the packages
pkgutilcmd="/usr/sbin/pkgutil"
receipts=$($pkgutilcmd --pkgs=com.macility.popchar3)
while read -r receipt; do
    $pkgutilcmd --pkgs="${receipt}" && $pkgutilcmd --forget "${receipt}"
done <<< "${receipts}"        

echo "PopChar deletion complete"
