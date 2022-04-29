#!/bin/bash

# Determine whether location services is enabled

location_services=$(/usr/bin/defaults read /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled 2>/dev/null)
timezone_active=$(/usr/bin/defaults read /Library/Preferences/com.apple.timezone.auto Active)

if [[ $location_services = 1 && $timezone_active ]]; then
    result="True"
else
    result="False"
fi

echo "<result>$result</result>"

exit 0