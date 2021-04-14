#!/bin/bash

# Ensure no leftover processes
/usr/bin/pgrep msudate && /usr/bin/pkill msupdate
/usr/bin/pgrep Microsoft\ Update\ Assistant && /usr/bin/pkill Microsoft\ Update\ Assistant

# Register MAU
# Source:
# https://macadmins.slack.com/archives/C29PWTQFM/p1582220729227800

echo "$(date): Registering Microsoft AutoUpdate.app, Microsoft AU Daemon.app, and Microsoft Update Assistant.app for all users."
for usr in /Users/*
do
    usrDir="$(cut -d/ -f3 <<<"echo $usr")"
    if /usr/bin/dscl . -list /Users | grep -iq "$usrDir"; then
        usrMatch="$usrDir"
    fi
    if [ "$usrMatch" != "" ] && [ "$usrMatch" != "Shared" ] && [ "$usrMatch" != "jamfmgmt" ] && [ "$usrMatch" != "Guest" ]; then
        if [ -e "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app" ]; then
            sudo -u "$usrMatch" /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -R -f -trusted "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app" ||:
        fi
        if [ -e "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AU Daemon.app" ]; then
            sudo -u "$usrMatch" /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -R -f -trusted "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AU Daemon.app" ||:
        fi
        if [ -e "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft Update Assistant.app" ]; then
            sudo -u "$usrMatch" /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -R -f -trusted "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft Update Assistant.app" ||:
        fi
        echo "$(date): Registered MAU for user $usrMatch."
    fi
done
