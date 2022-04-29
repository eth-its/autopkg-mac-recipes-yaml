#!/bin/bash

echo "Activating SPSS Statistics %MAJOR_VERSION% Node License"

# activate the license
echo "Running licenseactivator"
if ! cd "/Applications/IBM SPSS Statistics %MAJOR_VERSION%/Resources/Activation" ; then
    echo "Cannot activate as Activation files are missing."
    exit 1
fi

./licenseactivator -c %license_key% > /tmp/licenseactivator.txt

if grep "You are not allowed to generate any more new licenses" /tmp/licenseactivator.txt ; then
    echo "ERROR: SPSS Statistics %MAJOR_VERSION% Node License activation failed. No licenses remaining."
    exit 1
elif ! grep "Authorization succeeded" /tmp/licenseactivator.txt; then
    echo "ERROR: SPSS Statistics %MAJOR_VERSION% Node License activation failed."
    exit 1
else
    echo "SPSS %MAJOR_VERSION% Node License activation successful."
    mkdir -p /Library/Management/SPSSStatistics/%MAJOR_VERSION%
    touch /Library/Management/SPSSStatistics/%MAJOR_VERSION%/node_license_activated
    if rm /Library/Management/SPSSStatistics/%MAJOR_VERSION%/floating_license_present ; then 
        echo "Floating license indicator removed" 
    fi
fi
