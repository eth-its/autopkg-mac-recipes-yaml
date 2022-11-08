#!/bin/bash

# postinstall to install Element config json file and remove the old Riot app if it's there.
# config.json contents based on advice at:
# https://github.com/vector-im/riot-web/blob/master/docs/config.md#desktop-app-configuration

# Remove the old Riot apps
app_path="/Applications/Riot.app"
[[ -d "$app_path" ]] && /bin/rm -rf "$app_path"
app_path="/Applications/Element (Riot).app"
[[ -d "$app_path" ]] && /bin/rm -rf "$app_path"

# Get the logged-in user's username
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

echo "Setting Element app config for $loggedInUser ..."

# path to config.json
configfileloc="/Users/$loggedInUser/Library/Application Support/Element"

# remove any existing version of the config file
if ls "$configfileloc/config.json" 2>/dev/null; then 
    echo "Removing existing Element config file config.json..."
    rm -f "$configfileloc/config.json"
else
    echo "No existing Element config file config.json found"
fi

echo "Creating Element config file config.json..."

su -l "$loggedInUser" -c "mkdir -p \"$configfileloc\""
chown -R "$loggedInUser:staff" "$configfileloc"

su -l "$loggedInUser" -c "echo '{
    \"default_server_config\": {
        \"m.homeserver\": {
            \"base_url\": \"%DEFAULT_SERVER_URL%\"
        }
    },
    \"brand\": \"Element\"
}
' > \"$configfileloc/config.json\""

if [[ -f "$configfileloc/config.json" ]]; then
    echo "Config file was created at $configfileloc/config.json:"
    cat "$configfileloc/config.json"
else
    echo "Config file was not created"
    exit 1
fi
