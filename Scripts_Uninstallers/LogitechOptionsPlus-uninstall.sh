#!/bin/bash

#######################################################################
#
# Uninstalls Logitech Options Plus using the its own Uninstaller tool
#
#######################################################################

#Uninstall Logi Options and its helper tools

/Library/Application\ Support/Logitech.localized/LogiOptionsPlus/logioptionsplus_agent.app/Contents/Frameworks/logioptionsplus_updater.app/Contents/MacOS/logioptionsplus_updater --full --uninstall

#check if Logi Options was succesfully uninstalled

APP_PATH1="/Applications/logioptionsplus.app"
APP_PATH2="/Library/Application Support/Logitech.localized/LogiOptionsPlus"

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

# Success message based on the flags
if [[ "$removed1" == true && "$removed2" == true ]]; then
    echo "Logi Options+ has been successfully uninstalled."
    exit 0
else
    echo "Logi Options+ is still installed. Please check the listed paths." >&2
    exit 1
fi
