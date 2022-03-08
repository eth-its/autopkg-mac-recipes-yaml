#!/bin/bash

:<<DOC
Disable Electron Updates

This script uses launchctl to disable updates with Electro-based apps
such as Skype and Atom

See https://soundmacguy.wordpress.com/2018/02/25/microsoft-skype-definitely-and-teams-maybe-disabling-automatic-updates/
DOC


# Create the launchagent file in the library and write to it
launchagent="/Library/LaunchAgents/com.github.eth-its.disable-electron-update-notifications.plist"

# reset any old version
if [[ -f "$launchagent" ]]; then
    /bin/launchctl bootout "$launchagent" ||:
    /bin/rm "$launchagent"
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

/bin/launchctl enable system/com.github.eth-its.disable-electron-update-notifications
/bin/launchctl bootstrap system "$launchagent"
