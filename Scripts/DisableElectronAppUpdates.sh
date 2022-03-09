#!/bin/bash

:<<DOC
Disable Electron Updates

This script uses launchctl to disable updates with Electro-based apps
such as Skype and Atom

See https://soundmacguy.wordpress.com/2018/02/25/microsoft-skype-definitely-and-teams-maybe-disabling-automatic-updates/
DOC

# current logged-in user's short name
current_user=$(/bin/ls -la /dev/console | /usr/bin/cut -d " " -f 4)
uid=$(id -u "$current_user")
echo "Current user is $current_user"

# Create the launchagent file in the library and write to it
launchagent="/Library/LaunchAgents/com.github.eth-its.disable-electron-update-notifications.plist"

# reset any old version
if [[ -f "$launchagent" ]]; then
    if /bin/launchctl disable "user/$uid/com.github.eth-its.disable-electron-update-notifications"; then
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

cat > "$launchagent" <<END 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.github.eth-its.disable-electron-update-notifications</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/launchctl</string>
    <string>setenv</string>
    <string>DISABLE_UPDATE_CHECK</string>
    <string>1</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
END

# wait for 2 seconds
sleep 2

# adjust permissions correctly then load.
/usr/sbin/chown root:wheel "$launchagent"
/bin/chmod 644 "$launchagent"

if sudo -u "$current_user" -i /bin/launchctl load -F "$launchagent"; then
    echo "LaunchAgent successfully loaded"
else
    echo "LaunchAgent was not loaded."
fi

if sudo -u "$current_user" -i /bin/launchctl enable "user/$uid/com.github.eth-its.disable-electron-update-notifications"; then
    echo "LaunchAgent successfully enabled"
else
    echo "LaunchAgent was not enabled."
fi
