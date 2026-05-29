#!/bin/zsh

cat > /Library/Management/ETHZ/SupportApp/status_update.zsh << "EOF"
#!/bin/zsh

# Support App Extension - Status update (Runs every time the Support app is opened)

# Support App preference plist
support_pref_file="/Library/Preferences/nl.root3.support.plist"
managed_pref_file="/Library/Managed Preferences/nl.root3.support.plist"
rows_template="/Library/Management/ETHZ/SupportApp/Supportapp_rows_template.plist"

# Get admin and system defaults
SupportGroup=$(defaults read ${managed_pref_file} SupportGroup)
TicketLink=$(defaults read ${managed_pref_file} SecondRowLinkLeft)
KBTitle=$(defaults read ${managed_pref_file} FirstRowSubtitleLeft)
KBLink=$(defaults read ${managed_pref_file} FirstRowLinkLeft)
serialNumber=$(ioreg -c "IOPlatformExpertDevice" | awk -F '"' '/IOPlatformSerialNumber/ {print $4}')
selfservice=$(defaults read /Applications/ETH\ Self\ Service.app/Contents/Info.plist CFBundleIdentifier || echo com.jamf.selfserviceplus)

plist_commands=()
add_set_command() {
    local key_path="$1"
    local value="$2"
    [[ -n "$value" ]] && plist_commands+=(-c "Set ${key_path} ${value}")
}

# make sure the Rows dict exists already, if not, import the template
defaults read /Library/Preferences/nl.root3.support.plist Rows >/dev/null
if [[ $? -gt 0 ]] ; then
   /usr/libexec/PlistBuddy -c "Merge ${rows_template}" "$support_pref_file"
fi

# Populate items in the new Rows structure
add_set_command ":Rows:2:Items:0:Subtitle" ${KBTitle}
add_set_command ":Rows:2:Items:0:Action" ${KBLink}
add_set_command ":Rows:3:Items:0:Action" ${TicketLink}
add_set_command ":Rows:2:Items:1:Action" ${selfservice}

if [ -d "/Applications/Privileges.app" ]; then
    add_set_command ":Rows:3:Items:2:Title" 'Admin Rights' 
    add_set_command ":Rows:3:Items:2:Symbol" 'lock.fill'
    add_set_command ":Rows:3:Items:2:Subtitle" 'Add or Remove' 
    add_set_command ":Rows:3:Items:2:Action" 'corp.sap.privileges' 
else
    # fetch weather from wttr.in, at most once per hour
    currweather=/Library/Management/ETHZ/SupportApp/currentweather.txt
    if [ ! -f "$currweather" ] || [ $(( $(date +%s) - $(stat -f %m "$currweather" 2>/dev/null || echo 0) )) -gt 3600 ]; then
    	curl -fsS --max-time 4 'https://wttr.in/?format=%c%20%t'>$currweather
    fi
    weather=$(cat $currweather)
    add_set_command ":Rows:3:Items:2:Subtitle" 'Weather App'
    add_set_command ":Rows:3:Items:2:Symbol" 'cloud.sun.fill'
    add_set_command ":Rows:3:Items:2:Title" ${weather}
    add_set_command ":Rows:3:Items:2:Action" 'com.apple.weather' 
fi

if (( ${#plist_commands[@]} > 0 )); then
    /usr/libexec/PlistBuddy "${plist_commands[@]}" "$support_pref_file"
fi

defaults write "${support_pref_file}" FooterText -string "**This Mac is managed by $SupportGroup**\\n---------------------------------\\nSerial Number: $serialNumber"

EOF

cat > /Library/Management/ETHZ/SupportApp/Supportapp_rows_template.plist << "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Rows</key>
	<array>
		<dict>
			<key>Items</key>
			<array>
				<dict>
					<key>Type</key>
					<string>ComputerName</string>
				</dict>
				<dict>
					<key>Type</key>
					<string>MacOSVersion</string>
				</dict>
			</array>
		</dict>
		<dict>
			<key>Items</key>
			<array>
				<dict>
					<key>Type</key>
					<string>Uptime</string>
				</dict>
				<dict>
					<key>Type</key>
					<string>Storage</string>
				</dict>
			</array>
		</dict>
		<dict>
			<key>Items</key>
			<array>
				<dict>
					<key>ActionType</key>
					<string>URL</string>
					<key>Action</key>
					<string>action</string>
					<key>Symbol</key>
					<string>questionmark.circle.fill</string>
					<key>Title</key>
					<string>Need Help</string>
					<key>Subtitle</key>
					<string>loading..</string>
					<key>Type</key>
					<string>Button</string>

				</dict>
				<dict>
					<key>Action</key>
					<string>action</string>
					<key>ActionType</key>
					<string>App</string>
					<key>Subtitle</key>
					<string>Open the Self Service kiosk</string>
					<key>Symbol</key>
					<string>cart.fill</string>
					<key>Title</key>
					<string>ETH Self Service</string>
					<key>Type</key>
					<string>Button</string>
				</dict>
			</array>
		</dict>
		<dict>
			<key>Items</key>
			<array>
				<dict>
					<key>ActionType</key>
					<string>URL</string>
					<key>Action</key>
					<string>action</string>
					<key>Symbol</key>
					<string>ticket</string>
					<key>Title</key>
					<string>Open a ticket</string>
					<key>Type</key>
					<string>ButtonMedium</string>
				</dict>
				<dict>
					<key>Action</key>
					<string>com.cisco.secureclient.gui</string>
					<key>ActionType</key>
					<string>App</string>
					<key>Symbol</key>
					<string>point.3.connected.trianglepath.dotted</string>
					<key>Title</key>
					<string>Start VPN</string>
					<key>Type</key>
					<string>ButtonMedium</string>
				</dict>
				<dict>
					<key>ActionType</key>
					<string>App</string>
					<key>Action</key>
					<string>action</string>
					<key>Type</key>
					<string>ButtonMedium</string>
					<key>Symbol</key>
					<string>progress.indicator</string>
					<key>Title</key>
					<string>Loading..</string>
					<key>Subtitle</key>
					<string>Loading..</string>
				</dict>
			</array>
		</dict>
	</array>
</dict>
</plist>

EOF

chmod 755 /Library/Management/ETHZ/SupportApp/status_update.zsh
chown root:wheel /Library/Management/ETHZ/SupportApp/status_update.zsh

# remove old script if present
rm -f /Library/Management/ETHZ/SupportApp/SecondRowRight.zsh || true

# update status
/Library/Management/ETHZ/SupportApp/status_update.zsh