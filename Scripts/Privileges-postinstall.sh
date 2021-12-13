#!/bin/sh
## Privileges postinstall
## by Rupen Valand
## https://macadmins.slack.com/archives/C0560V3BQ/p1635785790353100?thread_ts=1635782325.348900&cid=C0560V3BQ
## Adapted by Graham Pugh based on an idea by James Smith 
## https://macadmins.slack.com/archives/C01AVR04ES1/p1637921154284300?thread_ts=1637917979.279500&cid=C01AVR04ES1


# Sets admin privileges for defined number of minutes
duration_minutes=%PRIVILEGES_ELEVATION_DURATION%
elevation_duration=$(( duration_minutes * 60 ))

# demote policy trigger name
demote_policy_trigger_name="Privileges-demote"

# Location for demotion script
script_location="/Library/Management/ETHZ/Privileges"

# make sure the demotion script location exists
mkdir -p "$script_location"

# Get current user
current_user=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

# Stop the current launchagent and remove it prior to installing this updated one
uid=$(id -u "$current_user")
/bin/launchctl asuser "$uid" /bin/launchctl unload -w "/Library/LaunchAgents/corp.sap.privileges.plist"
/bin/rm -f "/Library/LaunchAgents/corp.sap.privileges.plist"

# Wait for 2 seconds
Sleep 2

# write 
cat > "$script_location" <<END 
#!/bin/bash
su -l $current_user -c "/Applications/Privileges.app/Contents/Resources/PrivilegesCLI --add"

# now wait for the designated number of minutes
sleep $elevation_duration

# now remove privileges
# su -l $current_user -c "/Applications/Privileges.app/Contents/Resources/PrivilegesCLI --remove"
/usr/local/jamf/bin/jamf policy -event "$demote_policy_trigger_name"
END



# Create the launchagent file in the library and write to it
cat > /Library/LaunchAgents/corp.sap.privileges.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>corp.sap.privileges</string>
	<key>LimitLoadToSessionType</key>
	<string>Aqua</string>
	<key>ProgramArguments</key>
	<array>
		<string>/Applications/Privileges.app/Contents/Resources/PrivilegesCLI</string>
		<string>--remove</string>
	</array>
	<key>WatchPaths</key>
	<array>
		<string>/private/var/db/dslocal/nodes/Default/groups/admin.plist</string>
	</array>
</dict>
</plist>
EOF

# wait for 2 seconds
sleep 2

# adjust permissions correctly then load.
sudo /usr/sbin/chown root:wheel "/Library/LaunchAgents/corp.sap.privileges.plist"
sudo /bin/chmod 644 "/Library/LaunchAgents/corp.sap.privileges.plist"

uid=$(id -u "$current_user")
/bin/launchctl asuser "$uid" /bin/launchctl load -w "/Library/LaunchAgents/corp.sap.privileges.plist"

# add item to the dock
sudo -u "$current_user" -i /usr/bin/defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Privileges.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

/usr/bin/killall cfprefsd 
/usr/bin/killall Dock
