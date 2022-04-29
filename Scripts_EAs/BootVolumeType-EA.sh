#!/bin/sh

# Boot Volume Type
# Source: https://www.jamf.com/jamf-nation/feature-requests/6407/show-if-a-disk-is-apfs-or-hfs
# Returns the volume format type for the current boot volume.

echo "<result>$(diskutil info / | awk -F': ' '/File System/{print $NF}' | xargs)</result>"

exit 0