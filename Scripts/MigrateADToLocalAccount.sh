#!/bin/bash

# =======================================================================================
# MIGRATE ACTIVE DIRECTORY USER TO LOCAL USER
# G Pugh

# set up a log directory
LOGDIR="/Library/Management/ETH/logs/migrate_AD_to_local_account"
if [[ ! -d "$LOGDIR" ]]; then
	mkdir -p "$LOGDIR"
	chown -R root:wheel "$LOGDIR"
	chmod -R 755 "$LOGDIR"
fi

# jamfHelper location
JAMFHELPER="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

# create the log file if it does not exist
SERIALNUMBER=$(system_profiler SPHardwareDataType | awk '/Serial Number/ { print $4 }')
LOGFILE="$LOGDIR/$SERIALNUMBER.log"
LOGFILEERROR="$LOGDIR/$SERIALNUMBER""_ERROR.log"

# =======================================================================================
# User Variables

# current logged-in user's short name
current_user=$(/bin/ls -la /dev/console | /usr/bin/cut -d " " -f 4)
echo "Current user is $current_user" >> "$LOGFILE"

# Current Logged-in User's long name
user_realname=$(dscl . -read "/Users/$current_user" | awk '/^RealName:/,/^RecordName:/' | grep -v "RecordName" | tail -n 1 | sed 's/RealName://' | sed 's/^ //')
if [[ ! "$user_realname" ]]; then
	echo "Real Name not found. " >> "$LOGFILE"
	exit 1 # exit with an error
else
	echo "Real Name is $user_realname" >> "$LOGFILE"
fi

# Current Logged-in User's UID
local_uid=$(dscl /Local/Default -list /Users UniqueID | grep "$current_user" | awk '{print $2}')
if [[ "$local_uid" -le -1 || ! "$local_uid" ]]; then
	echo "Negative or absent UniqueID - cannot continue" >> "$LOGFILE"
	exit 1 # exit with an error
fi
echo "UID is $local_uid" >> "$LOGFILE"

# Current Logged-in User's GID
local_gid=$(dscl /Local/Default -list /Users gid | grep "$current_user" | awk '{print $2}')
echo "GID is $local_gid" >> "$LOGFILE"

# If GID is negative, set it to be the same as the UID
if [[ "$local_gid" -le -1  || ! "$local_gid" ]]; then
	echo "Negative or absent GID - must be set to the same as the UID" >> "$LOGFILE"
	local_gid="$local_uid"
	echo "GID is now $local_gid"  >> "$LOGFILE"
else
	echo "GID is not negative - continuing.." >> "$LOGFILE"
fi

# =======================================================================================
# OS Check and abort if older than El Capitan

system_build=$( /usr/bin/sw_vers -buildVersion )
if [[ "${system_build:0:2}" -ge 15 ]]; then
	echo "Mac is running El Capitan or above. OK to proceed."  >> "$LOGFILE"
else
	/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -heading 'Management Notice' -description "Error - OS X 10.11 or greater is required.  Cannot Continue.  Hit OK to Continue." -button1 "OK"
	echo "Running an older version of OS X. Aborting..."  >> "$LOGFILEERROR"
	exit 0 # exit with an error
fi

# =======================================================================================
# Check if we are already using a local account. Abort if so.

user_type=$(dscl /Search -read "/Users/$current_user" | grep AppleMetaNodeLocation | head -n 1 | cut -d / -f 2)

if [[ $user_type == "Local" ]]; then
	"$JAMFHELPER" -windowType utility -heading 'Account Migration' -description "This account is already a local account. Hit OK to Quit." -button1 "OK"
	echo "User had a local account so we are exiting." >> "$LOGFILEERROR"
	exit 0 # exit 0 as this isn't a failure
else
	echo "User does not have a local account, continuing." >> "$LOGFILE"
fi

# =======================================================================================
# Prompt user to enter their login password, repeat until matches

"$JAMFHELPER" -windowType utility -heading 'Account Migration' -description "The network account for $current_user will be converted to a local account. You will be asked for your account password." -button1 "Continue" -button2 "Cancel" -defaultButton 1 -cancelButton 2

if [[ $? -ne 0 ]]; then
	echo "User cancelled the script. Exiting." >> "$LOGFILEERROR"
	exit 1
fi

password_attempts=0

# Check to make sure passwords match; if they don't, display an error and prompt again.
while [[ "$login_password" != "$confirm_password" || -z "$login_password" ]]; do

	# ask for password
	login_password=$(/usr/bin/osascript <<EOT
		set myReply to text returned of (display dialog "Please enter your login password." ¬
		default answer "" ¬
			with title "Account Migration" ¬
			buttons {"Continue"} ¬
			default button 1 ¬
			with hidden answer)
EOT
	)

	# Confirm password.
	confirm_password=$(/usr/bin/osascript <<EOT
		set myReply to text returned of (display dialog "Please confirm your password" ¬
		default answer "" ¬
			with title "Account Migration" ¬
			buttons {"Continue"} ¬
			default button 1 ¬
			with hidden answer)
EOT
	)

	password_attempts=$((password_attempts+1))

	if [[ "$login_password" != "$confirm_password" ]]; then
		if [[ $password_attempts -le 4 ]]; then
			echo "Password mismatch... alerting user to try again"  >> "$LOGFILEERROR"
			/usr/bin/osascript <<EOT
				display dialog "Passwords do not match. Please try again." ¬
					with title "Management Notice" ¬
					buttons {"Continue."} ¬
					default button 1
EOT
		else
			/usr/bin/osascript <<EOT
				display dialog "You have entered mis-matching passwords five times. Please contact the Service Desk or closest TechCenter for assistance." ¬
					with title "Management Notice" ¬
					buttons {"Continue."} ¬
					default button 1
EOT
			echo "Entered mis-matching passwords too many times. Aborting." >> "$LOGFILEERROR"
			exit 2  # exit with an error status
		fi
	fi
done

# =======================================================================================
# Block screen with a full screen window during permissions changes

"$JAMFHELPER" -windowType fs -heading 'Management Notice' -description "Converting $current_user to a local user. Please wait until you are logged out. Then log back in. Please contact the Service Desk if you have any issues." -icon "/System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns" &
echo "Screen locked while performing migration" >> "$LOGFILE"

# =======================================================================================
# Delete the currently logged in user

sysadminctl -deleteUser "$current_user" -keepHome
echo "Mobile account deleted" >> "$LOGFILE"

# =======================================================================================
# Create the new local user

sysadminctl -addUser "$current_user" -UID "$local_uid" -fullName "$user_realname" -password "$login_password" -home /Users/"$current_user" -admin
echo "Local account created" >> "$LOGFILE"

# Fix GID for user
dscl . create /Users/"$current_user" PrimaryGroupID "$local_gid"
# re-add user to staff group
dseditgroup -o edit -a "$current_user" -t user staff
echo "GID updated" >> "$LOGFILE"

# =======================================================================================
# Remove old permissions and set new ownership and permissions on User's home directory

chown -Rf "$current_user:$local_gid" "/Users/$current_user"
# dscl . -append /Users/$current_user NFSHomeDirectory /Users/$current_user/
echo "Permissions fixed" >> "$LOGFILE"

## =======================================================================================
# kill jamfhelper and logout/exit

sleep 3
killall -9 jamfHelper
echo "All done ...exiting"  >> "$LOGFILE"

# force the logout (jamf needs PPPC permissions to do this)
osascript -e 'tell application "loginwindow" to  «event aevtrlgo»'
