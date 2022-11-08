#!/bin/zsh
# shellcheck shell=bash

# disable and remove Citrix Workspace LaunchAgent

if pgrep "Citrix Workspace"; then
    pkill "Citrix Workspace"
fi

# current logged-in user's short name
current_user=$(/bin/ls -la /dev/console | /usr/bin/cut -d " " -f 4)
uid=$(id -u "$current_user")
echo "Current user is $current_user"

launchagent="/Library/LaunchAgents/com.citrix.ReceiverHelper.plist"

# reset any old version
if [[ -f "$launchagent" ]]; then
    if /bin/launchctl disable "user/$uid/com.citrix.ReceiverHelper"; then
        echo "LaunchAgent successfully disabled"
    else
        echo "LaunchAgent was not disabled."
    fi
    if sudo -u "$current_user" -i /bin/launchctl unload -F "$launchagent"; then
        echo "LaunchAgent successfully unloaded"
    else
        echo "LaunchAgent was not unloaded."
    fi

    if /bin/rm "$launchagent"; then
        echo "LaunchAgent successfully deleted"
    else
        echo "LaunchAgent was not deleted."
    fi
fi
