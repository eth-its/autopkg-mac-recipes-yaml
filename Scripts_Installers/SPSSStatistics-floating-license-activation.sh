#!/bin/bash

echo "Activating SPSS Statistics %MAJOR_VERSION% Floating License"

# activate the license
echo "Running licenseactivator"
if ! cd "/Applications/IBM SPSS Statistics %MAJOR_VERSION%/Resources/Activation" ; then
    echo "Cannot activate as Activation files are missing."
    exit 1
fi

app_path=NOTSET
if [[ -d "/Applications/IBM SPSS Statistics %MAJOR_VERSION%/IBM SPSS Statistics.app" ]]; then app_path="/Applications/IBM SPSS Statistics %MAJOR_VERSION%/IBM SPSS Statistics.app" ; 
elif [[ -d "/Applications/IBM SPSS Statistics %MAJOR_VERSION%/SPSS Statistics.app" ]]; then app_path="/Applications/IBM SPSS Statistics %MAJOR_VERSION%/SPSS Statistics.app" ;
else echo "No existing installation present within '/Applications/IBM SPSS Statistics'" ; exit 1 ; fi 

installed_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$app_path/Contents/Info.plist" | cut -d. -f1)

# https://www.ibm.com/mysupport/s/defect/aCIKe000000g10Q/dt409141?language=en_US - app renames are hard. especially when the license team doesn't know about it ..
if [[ $installed_version -eq 30 ]] ; then 
mv "$app_path" "/Applications/IBM SPSS Statistics %MAJOR_VERSION%/SPSS Statistics.app"
./licenseactivator LSHOST=%FLOATING_LICENSE_URL% > /tmp/licenseactivator.txt
mv "/Applications/IBM SPSS Statistics %MAJOR_VERSION%/SPSS Statistics.app" "$app_path"
else
./licenseactivator LSHOST=%FLOATING_LICENSE_URL% > /tmp/licenseactivator.txt
fi

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
