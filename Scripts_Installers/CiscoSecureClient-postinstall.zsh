#!/bin/zsh
# shellcheck shell=bash

# remove Cisco Secure Client socket extension
# originally from Tyler in MacAdmins Slack:
# https://macadmins.slack.com/archives/CK38R7KPS/p1645729119584389?thread_ts=1645726163.719389&cid=CK38R7KPS

user=$(/usr/bin/stat -f %Su "/dev/console")

/usr/bin/su $user -c 'open "/opt/cisco/secureclient/bin/Cisco Secure Client - AnyConnect VPN Service.app"'

# give the extension a chance to be installed
timeout=60
i=1
while ! /usr/bin/systemextensionsctl list | grep acsockext; do
    sleep 1
    i=$((i+1))
    if [[ $i -ge $timeout ]]; then
        echo "ERROR: timed out - Skip deactivating of network extension acsockext"
        exit
    fi
done

echo "Deactivating network extension acsockext"
# Need to run as logged in user, as user needs to authorize the extension deactivation.
if /usr/bin/su $user -c '/Applications/Cisco/Cisco\ Secure\ Client\ -\ Socket\ Filter.app/Contents/MacOS/Cisco\ Secure\ Client\ -\ Socket\ Filter -deactivateExt' ; then
    echo "Network extension acsockext deactivated"
    # Remove the network extension KDF app.
    if /bin/rm -Rf "/Applications/Cisco/Cisco Secure Client - Socket Filter.app" ; then
        echo "Cisco Secure Client Socket Filter deleted"
    else
        echo "ERROR: Cisco Secure Client Socket Filter not deleted"
    fi
else
    echo "ERROR: Network extension acsockext not deactivated"
fi
