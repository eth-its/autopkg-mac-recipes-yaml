#!/bin/zsh

## make sure the homebrew ui app is installed as well - when on macOS26+,and when the user is an admin at the moment.
majoros=$(defaults read /System/Library/CoreServices/SystemVersion ProductVersion|sed -e 's/\..*//')
if [ -f /opt/homebrew/bin/brew ] ; then homebrew_binary=/opt/homebrew/bin/brew ; else homebrew_binary=/usr/local/bin/brew ; fi 
if [[ $majoros -ge "26" ]] ; then
    homebrew_user=$(stat -f%u $homebrew_binary)
    homebrew_shortname=$(id -P $homebrew_user|sed -e 's/:.*//')
    if [[ $(dscl . -read /Groups/admin GroupMembership) =~ ".*$homebrew_shortname.*" ]] ; then  
        sudo -H -iu \#$homebrew_user  $homebrew_binary install --cask homebrew-app -y
        ## also make sure that homebrew autoupdate is installed and trusted, so the user can configure it
        if [[ $(sudo -H -iu \#$homebrew_user $homebrew_binary tap|grep -c 'domt4/autoupdate') == 0 ]] ; then 
            sudo -H -iu \#$homebrew_user  $homebrew_binary tap domt4/autoupdate
            sudo -H -iu \#$homebrew_user  $homebrew_binary trust --command domt4/autoupdate/autoupdate
        fi 
    fi
fi
exit 0
