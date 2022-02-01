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

# Stop the current launchagent and remove it prior to installing this updated one
current_user=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$current_user")
/bin/launchctl asuser "$uid" /bin/launchctl unload -w "/Library/LaunchAgents/corp.sap.privileges.plist" ||:
/bin/rm -f "/Library/LaunchAgents/corp.sap.privileges.plist" ||:

# Wait for 2 seconds
Sleep 2

# write 
cat > "$demote_script_location/demote.sh" <<'END' 
#!/bin/bash

# Script Name:              RevokePrivileges.sh
# Script Author:            Peet McKinney @ Artichoke Consulting
# Desription
# This script revokes Privileges.app enabled user from admin group. The script accepts 1 argument for $timer. 
# The number of seconds before executing.

### Variables
# The assumption here is that user 501 should be the sole admin.
# However any admin name can be added to the ${valid_admins[@]} array
logged_in_user=$(scutil <<<"show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
valid_admins=(root ladmin spadmin)
timer=$1
if [[ ! "$timer" -eq "$timer" ]]; then
	timer=15
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

# We need to make sure to not de-privilege $FIRST_ADMIN
if [ -f "/Applications/Privileges.app/Contents/Resources/PrivilegesCLI" ] && ! array_contains valid_admins "$logged_in_user"; then
    su "$logged_in_user" -c "/Applications/Privileges.app/Contents/Resources/PrivilegesCLI --remove"
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
		<string>$elevation_duration</string>
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
