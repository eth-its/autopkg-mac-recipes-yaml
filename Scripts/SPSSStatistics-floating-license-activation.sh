#!/bin/bash

echo "Activating SPSS Statistics %MAJOR_VERSION% Floating License"

# activate the license
echo "Running licenseactivator"
if ! cd "/Applications/IBM SPSS Statistics %MAJOR_VERSION%/Resources/Activation" ; then
    echo "Cannot activate as Activation files are missing."
    exit 1
fi

./licenseactivator LSHOST=%FLOATING_LICENSE_URL% > /tmp/licenseactivator.txt

if ! grep %FLOATING_LICENSE_URL% "/Applications/IBM SPSS Statistics %MAJOR_VERSION%/Resources/Activation/commutelicense.ini" ; then
    echo "ERROR: SPSS Statistics %MAJOR_VERSION% Floating License activation failed."
    exit 1
else
    echo "SPSS Statistics %MAJOR_VERSION% Floating License activation successful."
    mkdir -p /Library/Management/SPSSStatistics/%MAJOR_VERSION%
    touch /Library/Management/SPSSStatistics/%MAJOR_VERSION%/floating_license_present
    if rm /Library/Management/SPSSStatistics/%MAJOR_VERSION%/node_license_activated ; then 
        # clear out the Node license 
        echo "" > "/Applications/IBM SPSS Statistics 27/Resources/Activation/lservrc"
        echo "Node license removed" 
    fi
fi
