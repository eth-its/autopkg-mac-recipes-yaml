#!/bin/bash

#######################################################################
#
# Uninstalls Ategra Web File Handler and its Starter App
#
#######################################################################

APP_PATH1="/Applications/ATEGRA Web File Handler.app"
APP_PATH2="/Applications/ATEGRA Web File Handler Starter.app"

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
