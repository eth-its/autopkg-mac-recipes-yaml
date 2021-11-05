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

echo "Script started at $(date)" >> "$LOGFILE"

# =======================================================================================
# User Variables

# current logged-in user's short name
current_user=$(/bin/ls -la /dev/console | /usr/bin/cut -d " " -f 4)
echo "Current user is $current_user" >> "$LOGFILE"

# Current Logged-in User's long name
user_realname=$(dscl . -read "/Users/$current_user" | awk '/^RealName:/,/^RecordName:/' | grep -v "RecordName" | tail -n 1 | sed 's/RealName://' | sed 's/^ //')
if [[ ! "$user_realname" ]]; then
	"$JAMFHELPER" -windowType utility -heading 'Account Migration' -description "Error - this account cannot be converted to a local account.  Please contact your IT administrator for assistance." -button1 "OK"
	echo "ERROR: Real Name not found. This is most likely not a mobile account" >> "$LOGFILE"
	exit 1 # exit with an error
else
	echo "Real Name is $user_realname" >> "$LOGFILE"
fi

# Current Logged-in User's UID
local_uid=$(dscl /Local/Default -list /Users UniqueID | grep "$current_user" | awk '{print $2}')
if [[ "$local_uid" -le -1 || ! "$local_uid" ]]; then
	"$JAMFHELPER" -windowType utility -heading 'Account Migration' -description "Error - this account cannot be converted to a local account.  Please contact your IT administrator for assistance." -button1 "OK"
	echo "ERROR: Negative or absent UniqueID - cannot continue" >> "$LOGFILE"
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
	"$JAMFHELPER" -windowType utility -heading 'Account Migration' -description "Error - OS X 10.11 or greater is required.  Cannot Continue.  Please contact your IT administrator for assistance." -button1 "OK"
	echo "ERROR: Running an older version of OS X. Aborting..."  >> "$LOGFILE"
	exit 0 # exit with an error
fi

# =======================================================================================
# Check if we are already using a local account. Abort if so.

user_type=$(dscl /Search -read "/Users/$current_user" | grep AppleMetaNodeLocation | head -n 1 | cut -d / -f 2)

if [[ $user_type == "Local" ]]; then
	"$JAMFHELPER" -windowType utility -heading 'Account Migration' -description "This account is already a local account. Click OK to Quit." -button1 "OK"
	echo "User had a local account so we are exiting." >> "$LOGFILE"
	exit 0 # exit 0 as this isn't a failure
else
	echo "User does not have a local account, continuing." >> "$LOGFILE"
fi

# =======================================================================================
# Prompt user to enter their login password, repeat until matches

echo "Informing user of the process." >> "$LOGFILE"

"$JAMFHELPER" -windowType utility -heading 'Account Migration' -description "The network account for $current_user will be converted to a local account. You will be asked for your account password.  Click OK to continue." -button1 "Continue" -button2 "Cancel" -defaultButton 1 -cancelButton 2

if [[ "$?" -ne 0 ]]; then
	echo "User cancelled the script. Exiting." >> "$LOGFILE"
	exit 0
fi

password_attempts=0

# Check to make sure passwords match; if they don't, display an error and prompt again.
while [[ "$login_password" != "$confirm_password" || -z "$login_password" ]]; do

	# ask for password
	login_password=$(/usr/bin/osascript <<END
		set myReply to text returned of (display dialog "Please enter your login password." ¬
		default answer "" ¬
			with title "Account Migration" ¬
			buttons {"Continue"} ¬
			default button 1 ¬
			with hidden answer)
END
	)

	# Confirm password.
	confirm_password=$(/usr/bin/osascript <<END
		set myReply to text returned of (display dialog "Please confirm your password" ¬
		default answer "" ¬
			with title "Account Migration" ¬
			buttons {"Continue"} ¬
			default button 1 ¬
			with hidden answer)
END
	)

	password_attempts=$((password_attempts+1))

	if [[ "$login_password" != "$confirm_password" ]]; then
		if [[ $password_attempts -le 2 ]]; then
			echo "ERROR: Password mismatch... alerting user to try again (attempt "$(( password_attempts + 1))  >> "$LOGFILE"
			/usr/bin/osascript <<END
				display dialog "Passwords do not match. Please try again." ¬
					with title "Account Migration" ¬
					buttons {"Continue"} ¬
					default button 1
END
		else
			/usr/bin/osascript <<END
				display dialog "You have entered mis-matching passwords too many times. Please contact your IT administrator for assistance." ¬
					with title "Account Migration" ¬
					buttons {"OK"} ¬
					default button 1
END
			echo "ERROR: Entered mis-matching passwords too many times. Aborting." >> "$LOGFILE"
			exit 2  # exit with an error status
		fi
	fi
done

# =======================================================================================
# Block screen with a full screen window during permissions changes

"$JAMFHELPER" -windowType fs -heading 'Account Migration' -description "Please wait a few moments while we convert your account. You will be logged out. Then log back in. Please contact your IT administrator if you have any issues." -icon "/System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns" &
echo "Screen locked while performing migration" >> "$LOGFILE"

# =======================================================================================
# Delete the currently logged in user

if sysadminctl -deleteUser "$current_user" -keepHome; then
	echo "Mobile account '$current_user' deleted" >> "$LOGFILE"
else
	killall -9 jamfHelper
	sleep 1
	"$JAMFHELPER" -windowType utility -heading 'Account Migration' -description "The account was unable to be converted (mobile account could not be removed). Please contact your IT administrator for assistance. Click OK to Quit." -button1 "OK"
	echo "ERROR: could not delete mobile account '$current_user'" >> "$LOGFILE"
	exit 3
fi

# =======================================================================================
# Create the new local user

if sysadminctl -addUser "$current_user" -UID "$local_uid" -fullName "$user_realname" -password "$login_password" -home /Users/"$current_user" -admin; then
	echo "Local account created" >> "$LOGFILE"
else
	killall -9 jamfHelper
	sleep 1
	"$JAMFHELPER" -windowType utility -heading 'Account Migration' -description "The account was unable to be converted (local account could not be created). Please contact your IT administrator for assistance. Click OK to Quit." -button1 "OK"
	echo "ERROR: could not create local account '$current_user'" >> "$LOGFILE"
	exit 4
fi

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


# =======================================================================================
# kill jamfhelper

sleep 3
killall -9 jamfHelper

# =======================================================================================
# Unbind machine if no AD accounts remaining

# look for accounts with an ID > 10000 (other than the one we just converted)
ad_accounts=$(dscl /Local/Default -list /Users UniqueID | grep -v "$local_uid" | awk '$2 > 10000')
if [[ ! $ad_accounts ]]; then
	echo "No other AD accounts on the device, so we can unbind" >> "$LOGFILE"
	# unbind - we need to provide an AD user so use the one we just converted
	if dsconfigad -remove -force -u "$current_user" -p "$login_password" ; then
		echo "Unbinding successful" >> "$LOGFILE"
		sleep 2
		jamf recon &
	else
		echo "ERROR: Unbinding failed" >> "$LOGFILE"
	fi
else
	"$JAMFHELPER" -windowType utility -heading 'Account Migration' -description "There are still network accounts on this device, so this Mac cannot be removed from the Active Directory. Please contact your IT administrator for assistance. Press OK to logout, and then please log back in." -button1 "OK"
fi

# =======================================================================================
# logout/exit

echo "All done ...exiting" >> "$LOGFILE"

# force the logout (jamf needs PPPC permissions to do this)
osascript -e 'tell application "loginwindow" to  «event aevtrlgo»'
