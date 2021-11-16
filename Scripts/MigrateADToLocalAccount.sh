#!/bin/bash

# Modified 2019-11-10
Version=2.0

: <<DOC
Original source is from MigrateUserHomeToDomainAcct.sh
Written by Patrick Gallagher - https://twitter.com/patgmac

Guidance and inspiration from Lisa Davies:
http://lisacherie.com/?p=239

Modified by Rich Trouton

Version 1.0 - Migrates an Active Directory mobile account to a local account by the following process:

1. Detect if the Mac is bound to AD and offer to unbind the Mac from AD if desired
2. Display a list of the accounts with a UID greater than 1000
3. Remove the following attributes from the specified account:

cached_groups
cached_auth_policy
CopyTimestamp - This attribute is used by the OS to determine if the account is a mobile account
SMBPrimaryGroupSID
OriginalAuthenticationAuthority
OriginalNodeName
SMBSID
SMBScriptPath
SMBPasswordLastSet
SMBGroupRID
PrimaryNTDomain
AppleMetaRecordName
MCXSettings
MCXFlags

4. Selectively modify the account's AuthenticationAuthority attribute to remove AD-specific attributes.
5. Restart the directory services process
6. Check to see if the conversion process succeeded by checking the OriginalNodeName attribute for the value "Active Directory"
7. If the conversion process succeeded, update the permissions on the account's home folder.
8. Prompt if admin rights should be granted for the specified account

Version 1.1

Changes:

1. After conversion, the specified account is added to the staff group.  All local accounts on this Mac are members of the staff group,
   but AD mobile accounts are not members of the staff group.
2. The "account_type" variable is now checking the AuthenticationAuthority attribute instead of the OriginalNodeName attribute. 
   The reason for Change 2's attributes change is that the AuthenticationAuthority attribute will exist following the conversion 
   process while the OriginalNodeName attribute may not.


Version 1.2

Changes:

Add RemoveAD function to handle the following tasks:

1. Force unbind the Mac from Active Directory
2. Deletes the Active Directory domain from the custom /Search and /Search/Contacts paths
3. Changes the /Search and /Search/Contacts path type from Custom to Automatic

Thanks to Rick Lemmon for the suggested changes to the AD unbind process.

Version 1.3

Changes:

Fix to account password backup and restore process. Previous versions 
of the script were adding extra quote marks to the account's plist 
file located in /var/db/dslocal/nodes/Default/users/.

Version 1.4

Changes:

macOS 10.14.4 will remove the the actual ShadowHashData key immediately 
if the AuthenticationAuthority array value which references the ShadowHash
is removed from the AuthenticationAuthority array. To address this, the
existing AuthenticationAuthority array will be modified to remove the Kerberos
and LocalCachedUser user values.

Thanks to the anonymous reporter who provided the bug report and fix.

Version 2.0
Modified by Graham Pugh
DOC

clear
echo

# =======================================================================================
# Setup

# set up a log directory
LOGDIR="/Library/Management/ETH/logs/migrate_AD_to_local_account"
if [[ ! -d "$LOGDIR" ]]; then
    mkdir -p "$LOGDIR"
    chown -R root:wheel "$LOGDIR"
    chmod -R 755 "$LOGDIR"
fi
# create the log file if it does not exist
SERIALNUMBER=$(system_profiler SPHardwareDataType | awk '/Serial Number/ { print $4 }')
LOG_FILE="$LOGDIR/$SERIALNUMBER.log"
exec > >(tee ${LOG_FILE}) 2>&1

FullScriptName=$(basename "$0")
echo "$FullScriptName Version $Version started at $(date)"


check4AD=$(/usr/bin/dscl localhost -list . | grep "Active Directory")

# Save current IFS state
OLDIFS=$IFS

IFS='.' read -r osvers_major osvers_minor _ <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state
IFS=$OLDIFS

# current logged-in user's short name
current_user=$(/bin/ls -la /dev/console | /usr/bin/cut -d " " -f 4)
uid=$(id -u "$current_user")
echo "Current user is $current_user"

# icon for dialog windows
dialog_icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GroupIcon.icns"
dialog_title="Migrate Mobile to Local Accounts"


# =======================================================================================
# Functions

RunAsRoot() {
    ##  Pass in the full path to the executable as $1
    if [[ "${USER}" != "root" ]] ; then
            /bin/echo
            /bin/echo "***  This application must be run as root.  Please authenticate below.  ***"
            /bin/echo
            sudo "${1}" && exit 0
    fi
}

RemoveAD() {
    # This function force-unbinds the Mac from the existing Active Directory domain
    # and updates the search path settings to remove references to Active Directory 

    searchPath=$(/usr/bin/dscl /Search -read . CSPSearchPath | grep Active\ Directory | sed 's/^ //')

    # Force unbind from Active Directory

    /usr/sbin/dsconfigad -remove -force -u none -p none
    
    # Deletes the Active Directory domain from the custom /Search
    # and /Search/Contacts paths
    
    /usr/bin/dscl /Search/Contacts -delete . CSPSearchPath "$searchPath"
    /usr/bin/dscl /Search -delete . CSPSearchPath "$searchPath"
    
    # Changes the /Search and /Search/Contacts path type from Custom to Automatic
    
    /usr/bin/dscl /Search -change . SearchPolicy dsAttrTypeStandard:CSPSearchPath dsAttrTypeStandard:NSPSearchPath
    /usr/bin/dscl /Search/Contacts -change . SearchPolicy dsAttrTypeStandard:CSPSearchPath dsAttrTypeStandard:NSPSearchPath
}

PasswordMigration() {
    # macOS 10.14.4 will remove the the actual ShadowHashData key immediately 
    # if the AuthenticationAuthority array value which references the ShadowHash
    # is removed from the AuthenticationAuthority array. To address this, the
    # existing AuthenticationAuthority array will be modified to remove the Kerberos
    # and LocalCachedUser user values.

    AuthenticationAuthority=$(/usr/bin/dscl -plist . -read "/Users/$netname" AuthenticationAuthority)
    Kerberosv5=$(echo "${AuthenticationAuthority}" | xmllint --xpath 'string(//string[contains(text(),"Kerberosv5")])' -)
    LocalCachedUser=$(echo "${AuthenticationAuthority}" | xmllint --xpath 'string(//string[contains(text(),"LocalCachedUser")])' -)
    
    # Remove Kerberosv5 and LocalCachedUser
    if [[ -n "${Kerberosv5}" ]]; then
        /usr/bin/dscl -plist . -delete "/Users/$netname" AuthenticationAuthority "${Kerberosv5}"
    fi
    
    if [[ -n "${LocalCachedUser}" ]]; then
        /usr/bin/dscl -plist . -delete "/Users/$netname" AuthenticationAuthority "${LocalCachedUser}"
    fi
}



# =======================================================================================
# Main body

RunAsRoot "${0}"

# =======================================================================================
# Select a user and unbind 

until [[ "$netname" == "false" ]]; do
    # get list of users with ID > 1000
    # requires shellcheck disable because the result is a single list item if it's quoted
    # but usernames cannot contain spaces so it's fine
    # shellcheck disable=SC2207
    listUsers=( $(/usr/bin/dscl . list /Users UniqueID | awk '$2 > 1000 {print $1}') )
    adUsers=()
    # loop through these users and check if they are actually AD accounts
    for username in "${listUsers[@]}"; do 
        echo "Checking $username..."
        account_type=$(/usr/bin/dscl . -read /Users/"$username" AuthenticationAuthority | head -2 | awk -F'/' '{print $2}' | tr -d '\n')
        
        # add AD accounts to the adUsers array
        if [[ "$account_type" = "Active Directory" ]]; then
            mobileusercheck=$(/usr/bin/dscl . -read /Users/"$username" AuthenticationAuthority | head -2 | awk -F'/' '{print $1}' | tr -d '\n' | sed 's/^[^:]*: //' | sed s/\;/""/g)
            if [[ "$mobileusercheck" = "LocalCachedUser" ]]; then
                echo "$username is an AD mobile account."
                adUsers=("${adUsers[@]}" "$username")
            else
                echo "The $username account is not a AD mobile account"
            fi
        else
            echo "The $username account is not a AD mobile account"
        fi
    done

    # stop here if there are no AD users to process
    if [[ ${#adUsers[@]} -eq 0 ]]; then
        echo "No AD users found"
        break
    fi

    # Dialog that explains to the user what is going to happen
    if [[ $uid ]]; then
        launchctl asuser "$uid" /usr/bin/osascript -e "
            display dialog \"You will be presented with a list of current Active Directory accounts on this computer.\" & return & return & \"Please select each user in turn that you wish to convert to a local account.\" & return & return & \"After each account is converted, you will be asked if you want the account to be an administerator or standard account.\" & return & return & \"Finally, you will be asked if you wish to unbind the computer from Active Directory.\" ¬
            buttons {\"Proceed\"} ¬
            default button 1 ¬
            with title \"$dialog_title\" ¬
            with icon POSIX file \"$dialog_icon\""
    fi

    # display a dialog that shows the list of AD users
    if [[ $uid ]]; then
        if ! netname="$(launchctl asuser "$uid" /usr/bin/osascript -e "
            choose from list the paragraphs of \"$(/usr/bin/printf '%s\n' "${adUsers[@]}")\" ¬
            with title \"$dialog_title\" ¬
            with prompt \"Please select a user to convert to a local account:\" ¬
            default items {\"$current_user\"} ¬
            multiple selections allowed false ¬
            empty selection allowed false ¬
            OK button name {\"Select\"} ¬
            cancel button name {\"Quit\"}
            tell result
                if it is false then error number -128 -- cancel
                set choice to first item
            end tell"
            )" ; then
            /bin/echo "User cancelled."
            exit 1
        fi
    else
        echo "Cannot show dialog so cannot continue"
        exit 1
    fi

    if [ "$netname" = "false" ]; then
        break
    fi
            
    # Remove the account attributes that identify it as an Active Directory mobile account
    /usr/bin/dscl . -delete "/users/$netname" cached_groups
    /usr/bin/dscl . -delete "/users/$netname" cached_auth_policy
    /usr/bin/dscl . -delete "/users/$netname" CopyTimestamp
    /usr/bin/dscl . -delete "/users/$netname" AltSecurityIdentities
    /usr/bin/dscl . -delete "/users/$netname" SMBPrimaryGroupSID
    /usr/bin/dscl . -delete "/users/$netname" OriginalAuthenticationAuthority
    /usr/bin/dscl . -delete "/users/$netname" OriginalNodeName
    /usr/bin/dscl . -delete "/users/$netname" SMBSID
    /usr/bin/dscl . -delete "/users/$netname" SMBScriptPath
    /usr/bin/dscl . -delete "/users/$netname" SMBPasswordLastSet
    /usr/bin/dscl . -delete "/users/$netname" SMBGroupRID
    /usr/bin/dscl . -delete "/users/$netname" PrimaryNTDomain
    /usr/bin/dscl . -delete "/users/$netname" AppleMetaRecordName
    /usr/bin/dscl . -delete "/users/$netname" PrimaryNTDomain
    /usr/bin/dscl . -delete "/users/$netname" MCXSettings
    /usr/bin/dscl . -delete "/users/$netname" MCXFlags

    # Migrate password and remove AD-related attributes
    PasswordMigration

    # Refresh Directory Services
    if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 7 ) ]]; then
        /usr/bin/killall DirectoryService
    else
        /usr/bin/killall opendirectoryd
    fi
    
    sleep 20
    
    account_type=$(/usr/bin/dscl . -read /Users/"$netname" AuthenticationAuthority | head -2 | awk -F'/' '{print $2}' | tr -d '\n')
    if [[ "$account_type" = "Active Directory" ]]; then
        /bin/echo "Something went wrong with the conversion process."
        /bin/echo "The $netname account is still an AD mobile account."

        if [[ $uid ]]; then
            launchctl asuser "$uid" /usr/bin/osascript -e "
                display dialog \"Something went wrong with the conversion process.\" & return & return & \"The $netname account is still an AD mobile account.\" ¬
                buttons {\"OK\"} ¬
                default button 1 ¬
                with title \"$dialog_title\" ¬
                with icon POSIX file \"$dialog_icon\""
        fi
        exit 1
    else
        /bin/echo "Conversion process was successful."
        /bin/echo "The $netname account is now a local account."
    fi
    
    homedir=$(/usr/bin/dscl . -read /Users/"$netname" NFSHomeDirectory  | awk '{print $2}')
    if [[ "$homedir" != "" ]]; then
        /bin/echo "Home directory location: $homedir"
        /bin/echo "Updating home folder permissions for the $netname account"
        /usr/sbin/chown -R "$netname" "$homedir"        
    fi
    
    # Add user to the staff group on the Mac
    /bin/echo "Adding $netname to the staff group on this Mac."
    /usr/sbin/dseditgroup -o edit -a "$netname" -t user staff
    
    /bin/echo "Displaying user and group information for the $netname account"
    /usr/bin/id "$netname"
    
    # Prompt to see if the local account should be give admin rights.
    if [[ $uid ]]; then
        answer=$(
            launchctl asuser "$uid" /usr/bin/osascript -e "
            set nameentry to button returned of (display dialog \"Do you want to give the $netname account admin rights?\" buttons {\"Yes\", \"No\"} default button \"Yes\" with icon POSIX file \"$dialog_icon\")")
    fi

    if [[ "$answer" == "Yes" ]]; then
        /usr/sbin/dseditgroup -o edit -a "$netname" -t user admin
        /bin/echo "Admin rights given to this account"
        finish_message="$netname is now a local admin user."
    else
        /bin/echo "No admin rights given"
        finish_message="$netname is now a local standard (non-admin) user."
    fi
    if [[ $uid ]]; then
        launchctl asuser "$uid" /usr/bin/osascript -e "
            display dialog \"Account conversion complete.\" & return & \"$finish_message.\" ¬
            buttons {\"OK\"} ¬
            default button 1 ¬
            with title \"$dialog_title\" ¬
            with icon POSIX file \"$dialog_icon\""
    fi
done

# =======================================================================================
# Check for AD binding and offer to unbind if found. 

if [[ "${check4AD}" == "Active Directory" ]]; then
    if ! answer=$(
        /usr/bin/osascript -e "
            set nameentry to button returned of ¬
            (display dialog \"Do you want to unbind this Mac from Active Directory?\" buttons {\"Yes\", \"No\"} default button \"Yes\" with icon POSIX file \"$dialog_icon\")"
        ); then
        /bin/echo "An error occurred."
        exit 1
    fi

    if [[ "$answer" == "Yes" ]]; then
        RemoveAD
        /bin/echo "Active Directory binding has been removed."
        finish_message="Active Directory binding has been removed"
    elif [[ "$answer" == "No" ]]; then
        /bin/echo "Active Directory binding is still active."
        finish_message="Active Directory binding is still active."
    fi
    if [[ $uid ]]; then
        launchctl asuser "$uid" /usr/bin/osascript -e "
            display dialog \"$finish_message.\" & return & return & \"The account conversion process is finished.\" & return & return & \"Please log out to complete the process.\" ¬
            buttons {\"OK\"} ¬
            default button 1 ¬
            with title \"$dialog_title\" ¬
            with icon POSIX file \"$dialog_icon\""
    fi
fi

