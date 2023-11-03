#!/bin/bash

# Deletes existing configuration and license-file. This is only needed transitioning from Prism 9 to Prism 10

# Delete configuration file from main Library
rm -f "/Library/Application Support/GraphPad/Prism/prism-config.xml"

# Delete license file from logged-in user
targetUser=$(who | grep console | awk '{ print $1 }')
rm -f "/Users/$targetUser/Library/Application Support/GraphPad/Prism/prism-license.qxt"

exit 0