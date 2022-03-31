#!/bin/zsh
# shellcheck shell=bash

: <<DOC
Adobe Creative Cloud Desktop app preinstall script
DOC

# de-serialize any existing Adobe apps before CCDA is installed
/usr/local/bin/jamf policy -event Run-AdobeUnserializer

# silently kill the application
app_name="Creative Cloud"
check_app_name="${app_name}.app"
if pgrep -f "/${check_app_name}" ; then
    echo "Closing $app_name"
    /usr/bin/osascript -e "quit app \"$app_name\"" &
    sleep 1

    # double-check
    n=0
    while [[ $n -lt 10 ]]; do
        if pgrep -f "/${check_app_name}" ; then
            (( n=n+1 ))
            sleep 1
            echo "Graceful close attempt # $n"
        else
            echo "$app_name closed."
            break
        fi
    done
    if pgrep -f "/${check_app_name}" ; then
        echo "$app_name failed to quit - killing."
        /usr/bin/pkill -f "/${check_app_name}"
    fi
fi

# remove the current user's Adobe folder before installing CCDA to prevent user issues
# (warning! this could break Acrobat Reader DC and/or Flash Player - might need to uninstall those too)
current_user=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
echo "Removing Adobe Application Support folder in $current_user home directory"
rm -rf "/Users/$current_user/Library/Application Support/Adobe" ||:
