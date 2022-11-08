#!/bin/bash

# SPSSStatistics %MAJOR_VERSION% license detector

if [[ -f "/Library/Management/SPSSStatistics/%MAJOR_VERSION%/node_license_activated" ]]; then
	license_type="Node"
elif [[ -f "/Library/Management/SPSSStatistics/%MAJOR_VERSION%/floating_license_present" ]]; then
	license_type="Floating"
else
	license_type="None"
fi

echo "<result>$license_type</result>"