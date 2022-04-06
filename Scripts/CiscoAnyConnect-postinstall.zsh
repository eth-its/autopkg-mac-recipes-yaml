#!/bin/zsh
# shellcheck shell=bash

# remove Cisco AnyConnect socket extension
# originally from Tyler in MacAdmins Slack:
# https://macadmins.slack.com/archives/CK38R7KPS/p1645729119584389?thread_ts=1645726163.719389&cid=CK38R7KPS

user=$(/usr/bin/stat -f %Su "/dev/console")
ACSOCKEXTACTIVE=$(/usr/bin/systemextensionsctl list | grep acsockext)

if [ ! "x${ACSOCKEXTACTIVE}" = "x" ]; then
    echo "Deactivating network extension acsockext"
    # Need to run as logged in user, as user needs to authorize the extension deactivation.
    /usr/bin/su $user -c '/Applications/Cisco/Cisco\ AnyConnect\ Socket\ Filter.app/Contents/MacOS/Cisco\ AnyConnect\ Socket\ Filter -deactivateExt'
    echo "Network extension acsockext deactivated"
    # Remove the network extension KDF app.
	# /bin/rm -rf "/Applications/Cisco/Cisco AnyConnect Socket Filter.app"
else
    echo "Skip deactivating of network extension acsockext"
fi