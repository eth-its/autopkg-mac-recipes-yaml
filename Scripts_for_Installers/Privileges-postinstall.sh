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

if [[ ! "$duration_minutes" ]]; then
    echo "No Privileges time limitation set. Exiting."
    exit 
fi

echo "Setting elevation time of $duration_minutes minute(s)."

elevation_duration=$(( duration_minutes * 60 ))

# Location for demotion script
demote_script_location="/Library/Management/ETHZ/Privileges"

# make sure the demotion script location exists
mkdir -p "$demote_script_location"

# Stop the current launchagent and remove it prior to installing this updated one
launchdaemon="/Library/LaunchDaemons/corp.sap.privileges.plist"
if [[ -f "$launchdaemon" ]]; then
    /bin/launchctl unload -F "$launchdaemon"
    /bin/rm "$launchdaemon"
fi

# Wait for 2 seconds
sleep 2

# write 
cat > "$demote_script_location/demote.sh" <<'END' 
#!/bin/bash

# Script Name:              RevokePrivileges.sh
# Script Author:            Peet McKinney @ Artichoke Consulting
# Desription
# This script revokes Privileges.app enabled user from admin group. The script accepts 1 argument for $timer. 
# The number of seconds before executing.

### Variables
# any admin name can be added to the ${valid_admins[@]} array
logged_in_user=$(scutil <<<"show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
valid_admins=(root ladmin spadmin jamfmgmt localadmin)
timer=$1
if [[ ! "$timer" ]]; then
	timer=900
fi

### Functions
# This is a quick check if string is in the array (usage -- array_contains ARRAY_NAME SEARCH_STRING)
array_contains() {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

# This checks all . /Users against ./Groups/admin to see if they're part of the group.
# (usage -- members GROUPNAME)
members() {
    dscl . -list /Users |
        while read -r user; do
            printf "%s " "$user"
            dsmemberutil checkmembership -U "$user" -G "$*"
        done | grep "is a member" | cut -d " " -f 1
}

### MAIN
# Delay time
sleep "$timer"


# We need to make sure to not de-privilege valid admins
if [ -f "/Applications/Privileges.app/Contents/Resources/PrivilegesCLI" ] && ! array_contains valid_admins "$logged_in_user"; then
    if su "$logged_in_user" -c "/Applications/Privileges.app/Contents/Resources/PrivilegesCLI --remove" ; then
    # if "/Applications/Privileges.app/Contents/Resources/PrivilegesCLI --remove" ; then
		echo "Privileges removed successfully"
	else
		echo "Privileges removal failed"
	fi
fi

# Check local users for membership in admin group.
members_admin=()
while IFS='' read -r line; do members_admin+=("$line"); done < <(members admin)

# Remove ${valid_admins[@]} from ${unique_members[@]}
for target in "${valid_admins[@]}"; do
    for i in "${!members_admin[@]}"; do
        if [[ ${members_admin[i]} = "$target" ]]; then
            unset 'members_admin[i]'
        fi
    done
done

# Finally remove all ${unique_members[@]} from the admin group
for del in "${members_admin[@]}"; do
    /usr/sbin/dseditgroup -o edit -d "$del" -t user admin
    echo "WARNING: Removed '$del' from admin group"
done
END

# Create the launchagent file in the library and write to it
# this is used to force demotion if the app is run normally
cat > "$launchdaemon" <<END 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Disabled</key>
	<false/>
	<key>Label</key>
	<string>corp.sap.privileges</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>$demote_script_location/demote.sh</string>
		<string>$elevation_duration</string>
	</array>
	<key>WatchPaths</key>
	<array>
		<string>/private/var/db/dslocal/nodes/Default/groups/admin.plist</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
END

# wait for 2 seconds
sleep 2

# adjust permissions correctly then load.
/usr/sbin/chown root:wheel "$launchdaemon"
/bin/chmod 644 "$launchdaemon"

/bin/launchctl load -w "$launchdaemon"
/bin/launchctl start corp.sap.privileges
