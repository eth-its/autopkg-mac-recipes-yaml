#!/bin/bash
####################################################################################################
#
# ABOUT
#
#   802.1X Disable automatic connection
#   SOURCE: https://www.jamf.com/jamf-nation/discussions/22628/get-802-1x-authentication-status-for-ethernet-via-script
#
####################################################################################################
#
# HISTORY
#
#   Version 1.0, 18-Mar-2015, Dan K. Snelson
#   Version 1.1, 19-Mar-2015, Dan K. Snelson, with inspiration from:
#   http://web.mit.edu/cron/system/macathena/core/scripts/imaging/macathenize/temp/macathenize_060813
#   Version 1.2, 22-Mar-2018, Graham Pugh. Corrected detection of existing plist
#   Version 1.3, 28-Feb-2020, Graham Pugh. Added detection of existing setting, so no change is made 
#                                          if unnecessary
#
####################################################################################################

loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
loggedInUserHome=$( /usr/bin/dscl . -read /Users/$loggedInUser | grep NFSHomeDirectory: | cut -c 19- | head -n 1 )
hardwareUUID=$( /usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | grep IOPlatformUUID | awk '{ print $3; exit; }' | sed 's/\"//g' )

/bin/echo "[$( date )] *** Disable 802.1X automatic connection ***"
/bin/echo "[$( date )] Logged-in User: $loggedInUser"
/bin/echo "[$( date )] Logged-in User Home: $loggedInUserHome"
/bin/echo "[$( date )] Hardware UUID: $hardwareUUID"

if find "$loggedInUserHome/Library/Preferences/ByHost/com.apple.network.eapolcontrol.$hardwareUUID.plist" -type f -exec ls -1t {} \; ; then
    EAC=$( /usr/libexec/PlistBuddy -c "Print :EthernetAutoConnect" "$loggedInUserHome/Library/Preferences/ByHost/com.apple.network.eapolcontrol.$hardwareUUID.plist" )
    if [[ ! $EAC ]] ; then
        /usr/libexec/PlistBuddy -c "Set :EthernetAutoConnect false" "$loggedInUserHome/Library/Preferences/ByHost/com.apple.network.eapolcontrol.$hardwareUUID.plist"
        /bin/echo "[$( date )] eapolcontrol plist modified (802.1X autoconnect disabled)"
    else
        /bin/echo "[$( date )] eapolcontrol plist not modified (802.1X autoconnect already disabled)"
    fi
else
    /usr/libexec/PlistBuddy -c "Add :EthernetAutoConnect bool" "$loggedInUserHome/Library/Preferences/ByHost/com.apple.network.eapolcontrol.$hardwareUUID.plist"
    /usr/libexec/PlistBuddy -c "Set :EthernetAutoConnect false" "$loggedInUserHome/Library/Preferences/ByHost/com.apple.network.eapolcontrol.$hardwareUUID.plist"
    /bin/echo "[$( date )] eapolcontrol plist created (802.1X autoconnect disabled)"
fi

# Respawn cfprefsd to load new preferences
/usr/bin/killall cfprefsd