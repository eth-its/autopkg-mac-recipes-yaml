#!/bin/bash

# Deletes existing configuration and license-file. This is only needed transitioning from Prism 9 to Prism 10

config_path="/Library/Application Support/GraphPad/Prism"
config_file="$config_path/prism-config.xml"

# Delete configuration file from main Library
rm -f $config_file

# Delete license file from logged-in user
targetUser=$(who | grep console | awk '{ print $1 }')
rm -f "/Users/$targetUser/Library/Application Support/GraphPad/Prism/prism-license.qxt"

exit 0