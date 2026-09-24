#!/bin/zsh
#If a user is logged on, notify that XQuartz Installation or Upgrade requires a reboot. 

CURRENT_USER=$(stat -f %Su /dev/console)
USER_ID=$(id -u "$CURRENT_USER")
if [ -z $USER_ID ] ; then exit 0 ; fi

#check if this is an initial installation - i.e, DISPLAY variable is not set. 
XQUARTZCONFIGURED=$(launchctl asuser $USER_ID /bin/launchctl getenv DISPLAY)

if [ -z $XQUARTZCONFIGURED ] ; then 
    launchctl bootstrap gui/$USER_ID /Library/LaunchAgents/org.xquartz.startx.plist 
    dialogbinary=/usr/local/bin/dialog
    if [[ ! -f $dialogbinary ]] ; then jamf policy -event "swiftDialog-install" ; fi  #if swift dialog is missing, install it
    launchctl asuser "$USER_ID" sudo -u "$CURRENT_USER" $dialogbinary  \
        --title "XQuartz installation requires logout and login" \
        --message "XQuartz was just installed on this Mac.\n\nPlease quit and restart any Terminal and other applications requiring XQuartz." \
        --button1text "Ok" \
        --icon "/Applications/Utilities/XQuartz.app" \
        --messagefont "size=16" \
        --ontop&
    disown
    exit 0
fi
