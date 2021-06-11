#!/bin/bash

#######################################################################
#
# Uninstall Maple
#
# Inputs required:
# Parameter 4: Major Version e.g. 2018
#
#######################################################################

exit_quit() {
    echo "Script could not be run because: $1"
    exit 1
}

# Parameters, as we need to account for major version
[[ $1 ]] && major_version="$1"
[[ $4 ]] && major_version="$4"
[[ ! $major_version ]] && exit_quit "no major version specified"

silent_app_quit() {
    # silently kill the application.
    if pgrep -f "/$app_name" ; then
        echo "Closing $app_name"
        /usr/bin/osascript -e "quit app \"$app_name\"" &
        sleep 1

        # double-check
        n=0
        while [[ $n -lt 10 ]]; do
            if pgrep -f "/$app_name" ; then
                (( n=n+1 ))
                sleep 1
				echo "Graceful close attempt # $n"
            else
                echo "$app_name closed."
                break
            fi
        done
        if pgrep -f "/$app_name" ; then
            echo "$app_name failed to quit - killing."
            /usr/bin/pkill -f "$app_name"
        fi
    fi
}

app_name="Maple $major_version.app"

# quit the app if running
silent_app_quit "$app_name"

echo "Deleting Maple $major_version"
yes | /Library/Frameworks/Maple.framework/Versions/$major_version/uninstall/uninstall.app/Contents/MacOS/osx-x86_64 --mode text

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --forget ch.ethz.mac.pkg.MapleSoft_Maple.EN ||:
