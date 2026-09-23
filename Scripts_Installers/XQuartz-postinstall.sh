#!/bin/zsh
#If a user is logged on, notify that XQuartz Installation or Upgrade requires a reboot. 

CURRENT_USER=$(stat -f %Su /dev/console)
USER_ID=$(id -u "$CURRENT_USER")

dialogbinary=/usr/local/bin/dialog
if [[ ! -f $dialogbinary ]] ; then jamf policy -event "swiftDialog-install" ; fi  #if swift dialog is missing, install it

if [ -z $USER_ID ] ; then exit 0 ; fi 

cat>/private/tmp/xquartzupdate-restart.sh<<EOT #deploy script to /tmp so it is deleted after reboot; substitute all variables except dialogresults
#!/bin/zsh
launchctl asuser "$USER_ID" sudo -u "$CURRENT_USER" $dialogbinary  \
        --title "XQuartz installation or Update" \
        --message "XQuartz was just installed or updated on this Mac.\n\nPlease restart your Mac to re-enable XQuartz supported application functionality." \
        --button1text "Restart now" \
        --button2text "I'll do it later" \
        --icon "/Applications/Utilities/XQuartz.app" \
        --messagefont "size=16" \
        --ontop
dialogResults=\$?
if [[ "\$dialogResults" == "0" ]]; then osascript -e 'tell application "System Events" to restart with state saving preference' ; fi
EOT

/bin/zsh /private/tmp/xquartzupdate-restart.sh& #launch script in the background, so as to not block further policies
disown
exit 0