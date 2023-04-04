#!/bin/zsh
# shellcheck shell=bash

# Turn off the Citrix Workspace Helper Tool

# kill the various processes
if /usr/bin/pgrep "Citrix Workspace"; then
    /usr/bin/pkill "Citrix Workspace"
fi

if /usr/bin/pgrep "AuthManager_Mac"; then
    /usr/bin/pkill "AuthManager_Mac"
fi

# current logged-in user's short name
current_user=$(/bin/ls -la /dev/console | /usr/bin/cut -d " " -f 4)
uid=$(/usr/bin/id -u "$current_user")
echo "Current user is $current_user (ID $uid)"

# set preference to remove the helper tool
/usr/bin/defaults write "/Users/$current_user/Library/Preferences/com.citrix.receiver.nomas.plist" ShowHelperInMenuBar 0
/usr/sbin/chown ${current_user}:staff "/Users/$current_user/Library/Preferences/com.citrix.receiver.nomas.plist"

# remove the launchagents to prevent launching at startup

helper_agent="com.citrix.ReceiverHelper"

if sudo -u $current_user /bin/launchctl list "$helper_agent"; then
    if /bin/launchctl bootout gui/$uid/$helper_agent; then
        echo "ReceiverHelper LaunchAgent successfully unloaded"
    else
        echo "ReceiverHelper LaunchAgent was not unloaded."
    fi

    if /bin/rm "/Library/LaunchAgents/$helper_agent.plist"; then
        echo "ReceiverHelper LaunchAgent successfully deleted"
    else
        echo "ReceiverHelper LaunchAgent was not deleted."
    fi
fi

web_agent="com.citrix.Weblauncher"

if sudo -u $current_user /bin/launchctl list "$web_agent"; then
    if /bin/launchctl bootout gui/$uid/$web_agent; then
        echo "WebLauncher LaunchAgent successfully unloaded"
    else
        echo "WebLauncher LaunchAgent was not unloaded."
    fi

    if /bin/rm "/Library/LaunchAgents/$web_agent.plist"; then
        echo "WebLauncher LaunchAgent successfully deleted"
    else
        echo "WebLauncher LaunchAgent was not deleted."
    fi
fi

echo "Written preferences to /Users/$current_user/Library/Preferences/com.citrix.receiver.nomas.plist"