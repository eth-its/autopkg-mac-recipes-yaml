#!/bin/bash 

if pkgutil --pkgs=org.fusioninventory-agent; then
    fusioninventory_agent_version=$(pkgutil --pkg-info org.fusioninventory-agent | grep version | sed 's|version: ||' | cut -d. -f -3)
else
    fusioninventory_agent_version="None"
fi

echo "<result>$fusioninventory_agent_version</result>"

exit 0