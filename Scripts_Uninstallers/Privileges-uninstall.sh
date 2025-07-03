#!/bin/bash

#######################################################################
#
# Privileges Uninstaller Script for Jamf Pro
#
#######################################################################

currentUser="$3"


/bin/sleep 2
for proc in Privileges PrivilegesAgent PrivilegesCLI; do
    if /usr/bin/pgrep -u "$currentUser" "$proc" >/dev/null 2>&1; then
        echo "Killing process: $proc"
        /usr/bin/sudo -u "$currentUser" /usr/bin/killall "$proc" >/dev/null 2>&1
    fi
done

# Remove the Application
/bin/rm -Rf /Applications/Privileges.app
echo "Privileges.app has been removed"


echo "Removing LaunchDaemons and related files"

shopt -s nullglob

# Unload and remove all matching LaunchAgents
for agent in /Library/LaunchAgents/corp.sap.privileges.*; do
    if [[ -f "$agent" ]]; then
        echo "Unloading and removing LaunchAgent: $agent"
        /bin/launchctl bootout gui/$(/usr/bin/id -u "$currentUser") "$agent" 2>/dev/null || echo "Failed to bootout LaunchAgent: $agent"
        /bin/rm -f "$agent"
    fi
done

# Unload and remove all matching LaunchDaemons
for daemon in /Library/LaunchDaemons/corp.sap.privileges.*; do
    if [[ -f "$daemon" ]]; then
        echo "Unloading and removing LaunchDaemon: $daemon"
        /bin/launchctl bootout system "$daemon" 2>/dev/null || echo "Failed to bootout LaunchDaemon: $daemon"
        /bin/rm -f "$daemon"
    fi
done

shopt -u nullglob

# Remove VoiceOver script
vo_script="/Library/Scripts/VoiceOver/Privileges Time Left.scpt"
if [[ -f "$vo_script" ]]; then
    echo "Removing VoiceOver script: $vo_script"
    /bin/rm -f "$vo_script"
fi

# Remove Application Support folder
app_support="/Library/Application Support/Privileges"
if [[ -d "$app_support" ]]; then
    echo "Removing Application Support folder: $app_support"
    /bin/rm -Rf "$app_support"
fi

# Remove paths.d entry
path_file="/private/etc/paths.d/PrivilegesCLI"
if [[ -f "$path_file" ]]; then
    echo "Removing paths.d file: $path_file"
    /bin/rm -f "$path_file"
fi

# Remove user data
echo "Removing user-specific Privileges data for $currentUser"

user_items=(
  "/Users/$currentUser/Library/Containers/corp.sap.privileges.*"
  "/Users/$currentUser/Library/Application Scripts/corp.sap.privileges*"
  "/Users/$currentUser/Library/Group Containers/7R5ZEU67FQ.corp.sap.privileges"
  "/Users/$currentUser/Library/Preferences/corp.sap.privileges*"
)

shopt -s nullglob
for item in "${user_items[@]}"; do
    for match in $item; do
        echo "Removing: $match"
        /bin/rm -Rf "$match"
    done
done
shopt -u nullglob

# Additional files to delete
echo "Deleting other files"
demote_script_location="/Library/Management/ETHZ/Privileges"
/bin/rm -Rf "$demote_script_location" ||:

# Forget installed packages if receipts exist
echo "Checking for installed Privileges package receipts"
for pkgid in com.sap.privileges corp.sap.privileges.pkg; do
    if ls "/private/var/db/receipts/${pkgid}"*.bom &>/dev/null; then
        echo "Forgetting package: $pkgid"
        /usr/sbin/pkgutil --forget "$pkgid" 2>/dev/null || echo "Package forget failed for $pkgid"
    fi
done

# make sure the current user has admin rights after uninstallation
isNotAdmin=$(/usr/bin/dsmemberutil checkmembership -U "$currentUser" -G admin | /usr/bin/grep -i "is not")

if [[ -n "$isNotAdmin" ]]; then
      /usr/sbin/dseditgroup -o edit -a "$currentUser" -t user admin
fi
