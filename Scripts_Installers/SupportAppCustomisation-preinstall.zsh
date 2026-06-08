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

    if [[ -f /usr/bin/jq ]] ; then wttr_query='j2' ; else wttr_query='%c%20%t' ; fi 

    if [[ ! -s "$weather_cache" || "$cache_age" -gt 3600 ]]; then
        /bin/mkdir -p "$support_app_dir"
        if /usr/bin/curl -fsS --max-time 4 "https://wttr.in/?format=$wttr_query" -o "$tmp_file" 2>/dev/null; then
            /bin/mv "$tmp_file" "$weather_cache"
        else
            /bin/rm -f "$tmp_file"
        fi
    fi
}

translate_weather_icon() { 
sf_symbol="cloud.sun.fill"
weather_code=$1

if [[ "$weather_code" == "113" ]]; then
    sf_symbol="sun.max.fill"

elif [[ "$weather_code" == "116" ]]; then
    sf_symbol="cloud.sun.fill"

elif [[ "$weather_code" == "119" ]]; then
    sf_symbol="cloud.fill"

elif [[ "$weather_code" == "122" ]]; then
    sf_symbol="smoke.fill"

elif [[ "$weather_code" == "143" || \
        "$weather_code" == "248" || \
        "$weather_code" == "260" ]]; then
    sf_symbol="cloud.fog.fill"

elif [[ "$weather_code" == "176" || \
        "$weather_code" == "263" || \
        "$weather_code" == "353" ]]; then
    sf_symbol="cloud.sun.rain.fill"

elif [[ "$weather_code" == "266" || \
        "$weather_code" == "293" || \
        "$weather_code" == "296" ]]; then
    sf_symbol="cloud.drizzle.fill"

elif [[ "$weather_code" == "299" || \
        "$weather_code" == "302" || \
        "$weather_code" == "305" || \
        "$weather_code" == "308" || \
        "$weather_code" == "356" || \
        "$weather_code" == "359" ]]; then
    sf_symbol="cloud.heavyrain.fill"

elif [[ "$weather_code" == "179" || \
        "$weather_code" == "182" || \
        "$weather_code" == "185" || \
        "$weather_code" == "281" || \
        "$weather_code" == "284" || \
        "$weather_code" == "311" || \
        "$weather_code" == "314" || \
        "$weather_code" == "317" || \
        "$weather_code" == "350" || \
        "$weather_code" == "362" || \
        "$weather_code" == "365" || \
        "$weather_code" == "374" || \
        "$weather_code" == "377" ]]; then
    sf_symbol="cloud.sleet.fill"

elif [[ "$weather_code" == "227" || \
        "$weather_code" == "320" || \
        "$weather_code" == "323" || \
        "$weather_code" == "326" || \
        "$weather_code" == "368" ]]; then
    sf_symbol="cloud.snow.fill"

elif [[ "$weather_code" == "230" || \
        "$weather_code" == "329" || \
        "$weather_code" == "332" || \
        "$weather_code" == "335" || \
        "$weather_code" == "338" || \
        "$weather_code" == "371" || \
        "$weather_code" == "395" ]]; then
    sf_symbol="snowflake"

elif [[ "$weather_code" == "200" || \
        "$weather_code" == "386" ]]; then
    sf_symbol="cloud.sun.bolt.fill"

elif [[ "$weather_code" == "389" ]]; then
    sf_symbol="cloud.bolt.rain.fill"

elif [[ "$weather_code" == "392" ]]; then
    sf_symbol="cloud.bolt.fill"
fi
echo "$sf_symbol"
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

    if [[ $wttr_query == 'j2' ]]; then 
        weather_symbol=$(translate_weather_icon $(echo $weather|jq -r '.current_condition[0].weatherCode'))
        weather_text="$(echo $weather|jq -r '.current_condition[0].FeelsLikeC')°C"
    else
        weather_symbol="cloud.sun.fill"
        weather_text=$weather
    fi
    add_set_command ":Rows:3:Items:2:Symbol" "$weather_symbol"
    add_set_command ":Rows:3:Items:2:Title" "$weather_text"
    add_set_command ":Rows:3:Items:2:Subtitle" "Weather App"
    add_set_command ":Rows:3:Items:2:Action" "com.apple.weather"
fi

if (( ${#plist_commands[@]} > 0 )); then
    /usr/libexec/PlistBuddy "${plist_commands[@]}" "$support_pref_file"
fi

# Set Values of Support App Content
/usr/bin/defaults write "$support_pref_file" FooterText -string "**This Mac is managed by $support_group**\\n---------------------------------\\nSerial Number: $serial_number"

# check if contents have changed; if so, restart cfprefsd
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