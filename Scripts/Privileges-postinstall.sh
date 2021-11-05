#!/bin/sh
## Privileges postinstall
## by Rupen Valand
## https://macadmins.slack.com/archives/C0560V3BQ/p1635785790353100?thread_ts=1635782325.348900&cid=C0560V3BQ

## Get current user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )


## Stop the current launchagent and remove it prior to installing this updated one

uid=$(id -u "$currentUser")
launchctl asuser $uid /bin/launchctl unload -w "/Library/LaunchAgents/corp.sap.privileges.plist"
rm -f "/Library/LaunchAgents/corp.sap.privileges.plist"


## Wait for 2 seconds
Sleep 2


## Create the launchagent file in the library and write to it

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
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>420</integer>
</dict>
</plist>
EOF

## Wait for 2 seconds. Because why not add a little grace?
sleep 2

## Adjust permissions correctly then load.
sudo chown root:wheel "/Library/LaunchAgents/corp.sap.privileges.plist"
sudo chmod 644 "/Library/LaunchAgents/corp.sap.privileges.plist"

uid=$(id -u "$currentUser")
launchctl asuser $uid /bin/launchctl load -w "/Library/LaunchAgents/corp.sap.privileges.plist"

/usr/local/bin/dockutil --add /Applications/Privileges.app
/usr/bin/killall cfprefsd 
/usr/bin/killall Dock
