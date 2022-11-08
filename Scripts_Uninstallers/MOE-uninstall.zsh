#!/bin/zsh
# shellcheck shell=bash

# Uninstall MOE - parameter 4 is the major version (also the folder name)

MAJOR_VERSION="$4"

# Inputted variables
appName="MOE.app"

function silent_app_quit() {
    # silently kill the application.
    appName="$1"
    if [[ $(pgrep -ix "$appName") ]]; then
        echo "Closing $appName"
        /usr/bin/osascript -e "quit app \"$appName\""
        sleep 1

        # double-check
        countUp=0
        while [[ $countUp -le 10 ]]; do
            if [[ -z $(pgrep -ix "$appName") ]]; then
                echo "$appName closed."
                break
            else
                let countUp=$countUp+1
                sleep 1
            fi
        done
        if [[ $(pgrep -x "$appName") ]]; then
            echo "$appName failed to quit - killing."
            /usr/bin/pkill "$appName"
        fi
    fi
}

if [[ -z "${appName}" ]]; then
    echo "No application specified!"
    exit 1
fi

# quit the app if running
silent_app_quit "$appName"

echo "Deleting MOE $MAJOR_VERSION"
find /Applications -name "moe*$MAJOR_VERSION" -type d -maxdepth 1 -exec /bin/rm -rf {} \;

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=ch.ethz.id.pkg.ChemCompMOE$MAJOR_VERSION && $pkgutilcmd --forget ch.ethz.id.pkg.ChemCompMOE$MAJOR_VERSION ||:
