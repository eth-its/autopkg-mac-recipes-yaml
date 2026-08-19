#!/bin/zsh
deletecreds() {
usershortname=$1
servername=$2
credspresent=''
credspresent=$(/usr/bin/security find-internet-password -s ${servername} /Users/${usershortname}/Library/Keychains/login.keychain|grep ${servername})
if [[ ! -z ${credspresent} ]]; then 
  echo "Deleting $servername password(s) for user $usershortname"
  /usr/bin/security delete-internet-password -s ${servername} /Users/${usershortname}/Library/Keychains/login.keychain
else
  echo "No passwords for ${servername} found for user ${usershortname}"
fi
}

loggedInUser=$(stat -f%Su /dev/console)
if [ "$loggedInUser" != "root" ]; then
  deletecreds ${loggedInUser} "pia01.d.ethz.ch"
  deletecreds ${loggedinUser} "pia02.d.ethz.ch"
else
    echo "No-one logged in. Exiting"
    exit 0
fi