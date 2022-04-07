#!/bin/bash
## preinstall script

# Installer will fail but report success if Java not already present
# so need to check for this
if ! /usr/libexec/java_home > /dev/null 2>&1; then
    echo "JDK not present but is required for app installation"
    /usr/local/bin/jamf policy -event "Eclipse Temurin 11-install"
fi
# double check
if ! /usr/libexec/java_home -v 11 > /dev/null 2>&1; then
    echo "Java installation failed. Aborting."
    exit 1
else
    # Find and set JAVA_HOME
    JAVA_HOME=$(/usr/libexec/java_home -v 11)
    export JAVA_HOME
fi
