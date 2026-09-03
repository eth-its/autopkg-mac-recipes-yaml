#!/bin/bash

# Lists local users with UID>500, that are not MDM managed. 
# based on : 
# mdm.managed.users @2025 Fleet Device Management
# Brock Walters (brock@fleetdm.com)

# set -x
# trap read debug

# functions

usrfnc(){
if [ "$EUID" != 0 ]
then
	echo "This script must be executed as the root user. Exiting..."; exit
fi
}

# NSData-valued fields (e.g. PushToken) print as a debug description like "{length = 32, bytes = 0x... };". Strip any such line.
mdmfnc(){
mdmdump="$(/usr/libexec/mdmclient DumpManagementStatus)"
mdminfo="$(/usr/libexec/mdmclient QueryDeviceInformation | /usr/bin/sed '/^=== CPF_GetInstalledProfiles === (<Device>)/d;/^Number of <Device> profiles found: /d')"
agntrsp="$(echo "$mdminfo" | /usr/bin/awk '/^Agent response: {/{flag=1;next}/^}$/{flag=0}flag' | /usr/bin/grep -v '= {length = ')"
dmonrsp="$(echo "$mdminfo" | /usr/bin/awk '/^Daemon response: {/{flag=1;next}/^}$/{flag=0}flag' | /usr/bin/grep -v '= {length = ')"
mgmtsts="$(echo "$mdmdump" | /usr/bin/awk '/^Management status: {/{flag=1;next}/^}$/{flag=0}flag' | /usr/bin/grep -v '= {length = ')"

if [ -z "$agntrsp" ] || [ -z "$dmonrsp" ] || [ -z "$mgmtsts" ]
then
	echo "This device does not seem to be enrolled in MDM. No management response. Exiting..."; exit 1
fi

agntrsp="$(printf '{\n%s\n}\n' "$agntrsp" | /usr/bin/plutil -convert json -o - -)"
dmonrsp="$(printf '{\n%s\n}\n' "$dmonrsp" | /usr/bin/plutil -convert json -o - -)"
mgmtsts="$(printf '{\n%s\n}\n' "$mgmtsts" | /usr/bin/plutil -convert json -o - -)"
mdmjson="$(/usr/bin/jq --argjson a "$agntrsp" --argjson d "$dmonrsp" --argjson m "$mgmtsts" -n '{"Agent response":$a,"Daemon response":$d,"Management status":$m}')"
}

#get a list of all shortnames of users with UID>500
luserfnc(){
localusers=$(/usr/bin/dscl . -readall /Users RecordName UniqueID|/usr/bin/awk 'NR>1 { if ($2+0==$2 && $2>500) print prev_line } { prev_line=$0 }'|/usr/bin/awk {'print $2'})
}

# operations

usrfnc; mdmfnc; luserfnc
mngduid="$(echo "$mdmjson" | /usr/bin/jq -c '."Daemon response".QueryResponses.ActiveManagedUsers // []')"

mngdusr="$(/usr/bin/dscl . -list /Users GeneratedUID | /usr/bin/jq -R -s -r --argjson managed "$mngduid" '
	split("\n")
	| map(select(length > 0) | capture("^(?<name>\\S+)\\s+(?<guid>\\S+)$"))
	| map(select(.guid as $g | $managed | index($g)))
	| map(.name)
	| join(" ")
')"

if [ -n "$mngdusr" ] ; then
    nonmdmusers=()
    for lusr in $localusers ; do
        if [[ ! $mngdusr =~ (" "|^)$lusr(" "|$) ]] ; then nonmdmusers+=$lusr' ' ; fi 
    done
    if [ ${#nonmdmusers[@]} == 0 ] ; then 
        echo "<result>All local users are MDM enabled</result>"
    else
        echo "<result>Non-MDM local users: $nonmdmusers</result>"
    fi
else
	echo "<result>No MDM enabled users found</result>"
fi