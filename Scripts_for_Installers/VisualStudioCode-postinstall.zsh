#!/bin/zsh
# shellcheck shell=bash

# postinstall to prevent VisualStudio Code updates
# in the settings.json contents based on advice at:
# https://code.visualstudio.com/Docs/supporting/FAQ#_how-do-i-opt-out-of-vs-code-autoupdates

# Get the logged-in user's username
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
echo "Logged in user: $loggedInUser"

# path to config.json
settingsfile="/Users/$loggedInUser/Library/Application Support/Code/User/settings.json"

echo "Creating settings.json if not present..."
mkdir -p "$(dirname "$settingsfile")"
/usr/sbin/chown "$loggedInUser":staff "$settingsfile"

if /usr/bin/grep -q "\"update.channel\":" "$settingsfile"; then
    # need to remove this line (legacy value)
    echo "Removing legacy settings..."
    /usr/bin/grep -v "\"update.channel\":" "$settingsfile" > "/var/tmp/code_settings.json" && /bin/mv "/var/tmp/code_settings.json" "$settingsfile"
fi

echo "Setting update channel for $loggedInUser..."
if /usr/bin/grep -q "\"update.mode\": \"none\"" "$settingsfile"; then
    # nothing to do
    echo "Updates in $settingsfile already disabled."
    exit 0
fi

if /usr/bin/grep -q "\"update.mode\":" "$settingsfile"; then
    # need to remove this line
    echo "Removing incorrect settings..."
    /usr/bin/grep -v "\"update.mode\":" "$settingsfile" > "/var/tmp/code_settings.json" && /bin/mv "/var/tmp/code_settings.json" "$settingsfile"
fi

if [[ $(tail -n 1 "$settingsfile") == "}" ]]; then
    # now remove last line if it is a '}'
    /usr/bin/sed -i '' -e '$ d' "$settingsfile"
    # add the update line
    echo "Adding correct settings..."
    echo '    "update.mode": "none"' >> "$settingsfile"
    echo '}' >> "$settingsfile"
    echo "Updates in $settingsfile now disabled."
else
    echo "Aborting as file has unexpected last line"
fi
