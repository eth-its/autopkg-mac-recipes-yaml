#!/bin/bash
####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE
# IS UNDER NO OBLIGATION TO SUPPORT, DEBUG, OR OTHERWISE
# MAINTAIN THIS SCRIPT
#
####################################################################################################

server="$5"

jHelper="/Library/Application Support/JAMF/bin/jamfHelper.app"
mgmtAction="/Library/Application Support/JAMF/bin/Management Action.app"
tmpDir="/Library/Application Support/JAMF/tmp"
appSupport="/Library/Application Support/JAMF/bin/"

rm -rf "$jHelper"
rm -rf "$mgmtAction"
rm -rf "$tmpDir"

curl "$server"/bin/jamfNotificationService.tar.gz -o /tmp/jns.tar.gz
curl "$server"/bin/jamfHelper.tar.gz -o /tmp/jHelper.tar.gz

tar -xf /tmp/jns.tar.gz -C "$appSupport"
tar -xf /tmp/jHelper.tar.gz -C "$appSupport"

chown -R root:wheel "$jHelper"
chown -R root:wheel "$mgmtAction"

rm /tmp/jns.tar.gz
rm /tmp/jHelper.tar.gz

exit 0		## Success
exit 1		## Failure
