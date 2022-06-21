#!/bin/zsh
# shellcheck shell=bash

# Activates Maple with the requested license

# Major version e.g. 2021
MAJOR_VERSION="$4"

# License, must be exactly 'node' or 'floating'
LICENSE_TYPE="$5"

if [[ $LICENSE_TYPE != "Floating" && $LICENSE_TYPE != "Node" ]]; then
    echo "ERROR: invalid license type specified"
    exit 1
fi

# management directory. This is specified in the Maple.pkg recipe - do not change!
management_dir="/Library/Management/ETHZ/Maple"

silent_app_quit() {
    # silently kill the application.
    # add .app to end of string if not supplied
    app_name="${app_name/\.app/}"            # remove any .app
    check_app_name="${app_name/\(/\\(}"       # escape any brackets for the pgrep
    check_app_name="${check_app_name/\)/\\)}"  # escape any brackets for the pgrep
    check_app_name="${check_app_name}.app"     # add the .app back
    if pgrep -f "/${check_app_name}" ; then
        echo "Closing $check_app_name"
        /usr/bin/osascript -e "quit app \"$app_name\"" &
        sleep 1

        # double-check
        n=0
        while [[ $n -lt 10 ]]; do
            if pgrep -f "/$check_app_name" ; then
                (( n=n+1 ))
                sleep 1
				echo "Graceful close attempt # $n"
            else
                echo "$app_name closed."
                break
            fi
        done
        if pgrep -f "/$check_app_name" ; then
            echo "$check_app_name failed to quit - killing."
            /usr/bin/pkill -f "/$check_app_name"
        fi
    fi
}

# move the license into place
if [[ -f "$management_dir/.$LICENSE_TYPE.license" ]]; then
    # quit the app if running
    app_name="Maple $MAJOR_VERSION"
    silent_app_quit "$app_name"

    /bin/cp "$management_dir/.$LICENSE_TYPE.license" /Library/Frameworks/Maple.framework/Versions/current/license
    echo "$LICENSE_TYPE license activated"
else
    echo "ERROR: $LICENSE_TYPE license file not found"
    exit 1
fi