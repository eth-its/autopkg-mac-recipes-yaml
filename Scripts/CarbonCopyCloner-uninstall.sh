#!/bin/bash

#######################################################################
#
# Uninstall Carbon Copy Cloner
#
#######################################################################

function silent_app_quit() {
    # silently kill the application.
    # add .app to end of string if not supplied
    app_name="${app_name/\.app/}"            # remove any .app
    check_app_name="${app_name/\(/\\(}"       # escape any brackets for the pgrep
    check_app_name="${check_app_name/\)/\\)}"  # escape any brackets for the pgrep
    check_app_name="${check_app_name}.app"     # add the .app back
    if pgrep -f "/${check_app_name}" ; then
        echo "Closing $app_name"
        /usr/bin/osascript -e "quit app \"$app_name\"" &
        sleep 1

        # double-check
        n=0
        while [[ $n -lt 10 ]]; do
            if pgrep -f "$check_app_name" ; then
                (( n=n+1 ))
                sleep 1
				echo "Graceful close attempt # $n"
            else
                echo "$app_name closed."
                break
            fi
        done
        if pgrep -f "$check_app_name" ; then
            echo "$app_name failed to quit - killing."
            /usr/bin/pkill -f "$check_app_name"
        fi
    fi
}

# MAIN

app_name="Carbon Copy Cloner"

# quit the app if running
silent_app_quit "$app_name"

# Run CCC's built-in uninstaller
echo "Removing application: ${app_name}"

ccc_uninstaller="/Applications/Carbon Copy Cloner.app/Contents/Resources/uninstall"
if [[ -f "$ccc_uninstaller" ]]; then 
	"$ccc_uninstaller"
else
	echo "no $app_name uninstaller found"
fi

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=com.bombich.ccc && $pkgutilcmd --forget com.bombich.ccc

echo "${app_name} removal complete!"
