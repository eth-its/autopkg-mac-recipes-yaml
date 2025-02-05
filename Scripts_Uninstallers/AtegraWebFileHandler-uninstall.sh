#!/bin/bash

#######################################################################
#
# Uninstalls Ategra Web File Handler and its Starter App
#
#######################################################################

APP_PATH1="/Applications/ATEGRA Web File Handler.app"
APP_PATH2="/Applications/ATEGRA Web File Handler Starter.app"

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

app_name="ATEGRA Web File Handler"

# quit the app if running
silent_app_quit "$app_name"

#Uninstall Ategra Web File Handler

rm -rf "$APP_PATH1"
rm -rf "$APP_PATH2"

#check if both were sucessfully deleted


# Initialize flags for the paths
removed1=true
removed2=true

# Check for the existence of paths and output messages
if [[ -d "$APP_PATH1" ]]; then
    echo " - $APP_PATH1 still exists." >&2
    removed1=false
fi

if [[ -d "$APP_PATH2" ]]; then
    echo " - $APP_PATH2 still exists." >&2
    removed2=false
fi

# Forget packages
echo "Forgetting packages"
/usr/sbin/pkgutil --forget ch.ategra.awfh.pkg

# Success message based on the flags
if [[ "$removed1" == true && "$removed2" == true ]]; then
    echo "ATEGRA Web File Handler has been successfully uninstalled."
    exit 0
else
    echo "ATEGRA Web File Handler is still installed. Please check the listed paths." >&2
    exit 1
fi
