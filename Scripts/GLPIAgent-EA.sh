#!/bin/bash 

if pkgutil --pkgs=org.glpi-project.glpi-agent; then
    glpi_agent_version=$(pkgutil --pkg-info org.glpi-project.glpi-agent | grep version | sed 's|version: ||')
else
    glpi_agent_version="None"
fi

echo "<result>$glpi_agent_version</result>"

exit 0