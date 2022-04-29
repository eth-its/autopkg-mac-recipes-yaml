#!/bin/zsh
# shellcheck shell=bash

# Uninstall MATLAB

# matlab version
matlab_version=%MAJOR_VERSION%

function silent_app_quit() {
    # silently kill the application.
    appName="MATLAB"
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

if [[ -d "/Applications/MATLAB_${matlab_version}_Floating.app" ]]; then
    app_dir="/Applications/MATLAB_${matlab_version}_Floating.app"
elif [[ -d "/Applications/MATLAB_${matlab_version}_Node.app" ]]; then
    app_dir="/Applications/MATLAB_${matlab_version}_Node.app"
elif [[ -d "/Applications/MATLAB_${matlab_version}.app" ]]; then
    app_dir="/Applications/MATLAB_${matlab_version}.app"
else
    echo "MATLAB_${matlab_version} not found, nothing to do."
    exit
fi

# quit the app if running
silent_app_quit

# Now remove the app
echo "Removing application: ${app_dir}"

# Manual list of files to remove
rm -rf "$app_dir"

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=ch.ethz.id.pkg.MATLABInstaller && $pkgutilcmd --forget ch.ethz.id.pkg.MATLABInstaller ||:

