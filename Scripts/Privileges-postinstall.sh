#!/bin/bash

:<<DOC
Privileges postinstall
by Rupen Valand
https://macadmins.slack.com/archives/C0560V3BQ/p1635785790353100?thread_ts=1635782325.348900&cid=C0560V3BQ

Adapted by Graham Pugh based on an idea by James Smith 
https://macadmins.slack.com/archives/C01AVR04ES1/p1637921154284300?thread_ts=1637917979.279500&cid=C01AVR04ES1
DOC

# Sets admin privileges for defined number of minutes
# takes parameter 4 from Jamf
duration_minutes="$4"

if [[ ! "$duration_minutes" -eq "$duration_minutes" ]]; then
	echo "No elevaton duration set, so not enforcing any time restriction. Quitting postinstall script."
	exit
fi

elevation_duration=$(( duration_minutes * 60 ))

# Location for demotion script
demote_script_location="/Library/Management/ETHZ/Privileges"

# make sure the demotion script location exists
mkdir -p "$demote_script_location"

# Get current user
current_user=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

# Stop the current launchagent and remove it prior to installing this updated one
uid=$(id -u "$current_user")
/bin/launchctl asuser "$uid" /bin/launchctl unload -w "/Library/LaunchAgents/corp.sap.privileges.plist" ||:
/bin/rm -f "/Library/LaunchAgents/corp.sap.privileges.plist" ||:

# Wait for 2 seconds
Sleep 2

# write 
cat > "$demote_script_location/demote.sh" <<END 
#!/bin/bash
su -l $current_user -c "/Applications/Privileges.app/Contents/Resources/PrivilegesCLI --add"
jamf recon  # do a recon to inform Jamf that the user is an admin

# now wait for the designated number of minutes
sleep $elevation_duration

# now remove privileges
su -l $current_user -c "/Applications/Privileges.app/Contents/Resources/PrivilegesCLI --remove"
jamf recon  # do a recon to inform Jamf that the user is no longer an admin
END

# Create the launchagent file in the library and write to it
# this is used to force demotion if the app is run normally
cat > "/Library/LaunchAgents/corp.sap.privileges.plist" <<END 
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
		<string>/bin/bash</string>
		<string>$demote_script_location/demote.sh</string>
	</array>
	<key>WatchPaths</key>
	<array>
		<string>/private/var/db/dslocal/nodes/Default/groups/admin.plist</string>
	</array>
</dict>
</plist>
END

# wait for 2 seconds
sleep 2

# adjust permissions correctly then load.
sudo /usr/sbin/chown root:wheel "/Library/LaunchAgents/corp.sap.privileges.plist"
sudo /bin/chmod 644 "/Library/LaunchAgents/corp.sap.privileges.plist"

uid=$(id -u "$current_user")
/bin/launchctl asuser "$uid" /bin/launchctl load -w "/Library/LaunchAgents/corp.sap.privileges.plist"
