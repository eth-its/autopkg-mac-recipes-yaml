#!/bin/zsh

cat > /Library/Management/ETHZ/SupportApp/status_update.zsh << "EOF"
#!/bin/zsh

# Support App Extension - Status update (Runs every time the Support app is opened)

# Support App preference plists
support_pref_file="/Library/Preferences/nl.root3.support.plist"
managed_pref_file="/Library/Managed Preferences/nl.root3.support.plist"
support_app_dir="/Library/Management/ETHZ/SupportApp"
rows_template="${support_app_dir}/Supportapp_rows_template.plist"
weather_cache="${support_app_dir}/currentweather.txt"

read_default() {
    local plist="$1"
    local key="$2"
    local fallback="$3"
    local value

    value=$(/usr/bin/defaults read "$plist" "$key" 2>/dev/null)
    if [[ -n "$value" ]]; then
        /bin/echo -n "$value"
    else
        /bin/echo -n "$fallback"
    fi
}

add_set_command() {
    local key_path="$1"
    local value="$2"

    [[ -n "$value" ]] && plist_commands+=(-c "Set ${key_path} ${value}")
}

refresh_weather_cache() {
    local cache_age=0
    local tmp_file="${weather_cache}.$$"

    if [[ -f "$weather_cache" ]]; then
        cache_age=$(( $(/bin/date +%s) - $(/usr/bin/stat -f %m "$weather_cache" 2>/dev/null || /bin/echo 0) ))
    fi

    if [[ ! -s "$weather_cache" || "$cache_age" -gt 3600 ]]; then
        /bin/mkdir -p "$support_app_dir"
        if /usr/bin/curl -fsS --max-time 4 "https://wttr.in/?format=%c%20%t" -o "$tmp_file" 2>/dev/null; then
            /bin/mv "$tmp_file" "$weather_cache"
        else
            /bin/rm -f "$tmp_file"
        fi
    fi
}

# Get admin and system defaults
support_group=$(read_default "$managed_pref_file" "SupportGroup" "ETH Zurich")
ticket_link=$(read_default "$managed_pref_file" "SecondRowLinkLeft" "")
kb_title=$(read_default "$managed_pref_file" "FirstRowSubtitleLeft" "")
kb_link=$(read_default "$managed_pref_file" "FirstRowLinkLeft" "")
serial_number=$(/usr/sbin/ioreg -c "IOPlatformExpertDevice" | /usr/bin/awk -F'"' '/IOPlatformSerialNumber/ {print $4; exit}')
selfservice=$(read_default "/Applications/ETH Self Service.app/Contents/Info.plist" "CFBundleIdentifier" "com.jamf.selfserviceplus")

# get a sha256 to check if file contents changed
cs_before=$(openssl sha256 -hex /Library/Preferences/nl.root3.support.plist|awk {'print $2'})

# Make sure the Rows dict exists already, if not, import the template.
if ! /usr/bin/defaults read "$support_pref_file" Rows >/dev/null 2>&1; then
    if [[ -f "$rows_template" ]]; then
        /usr/libexec/PlistBuddy -c "Merge ${rows_template}" "$support_pref_file"
    else
        exit 1
    fi
fi

plist_commands=()

# Populate items in the new Rows structure.
add_set_command ":Rows:2:Items:0:Subtitle" "$kb_title"
add_set_command ":Rows:2:Items:0:Action" "$kb_link"
add_set_command ":Rows:3:Items:0:Action" "$ticket_link"
add_set_command ":Rows:2:Items:1:Action" "$selfservice"

if [[ -d "/Applications/Privileges.app" ]]; then
    add_set_command ":Rows:3:Items:2:Title" "Admin Rights"
    add_set_command ":Rows:3:Items:2:Symbol" "lock.fill"
    add_set_command ":Rows:3:Items:2:Subtitle" "Add or Remove"
    add_set_command ":Rows:3:Items:2:Action" "corp.sap.privileges"
else
    refresh_weather_cache
    weather="Weather"
    [[ -s "$weather_cache" ]] && weather="$(<"$weather_cache")"

    add_set_command ":Rows:3:Items:2:Subtitle" "Weather App"
    add_set_command ":Rows:3:Items:2:Symbol" "cloud.sun.fill"
    add_set_command ":Rows:3:Items:2:Title" "$weather"
    add_set_command ":Rows:3:Items:2:Action" "com.apple.weather"
fi

if (( ${#plist_commands[@]} > 0 )); then
    /usr/libexec/PlistBuddy "${plist_commands[@]}" "$support_pref_file"
fi

# Set Values of Support App Content
/usr/bin/defaults write "$support_pref_file" FooterText -string "**This Mac is managed by $support_group**\\n---------------------------------\\nSerial Number: $serial_number"

# check if contents have changed; if so, restart cfprefsd and Support app
cs_after=$(openssl sha256 -hex /Library/Preferences/nl.root3.support.plist|awk {'print $2'})
 
if [[ ${cs_before} != ${cs_after} ]] ; then 
killall cfprefsd
touch "$support_pref_file"
killall cfprefsd
fi

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