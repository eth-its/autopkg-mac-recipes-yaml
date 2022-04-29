#!/bin/bash
# Reset Privacy Preferences (TCC) settings

# note that it is not possible to reset the settings for 'Location' so this is omitted from the list

SERVICES=('Calendar' 'AddressBook' 'SystemPolicyAllFiles' 'PostEvent' 'Willow' 'Photos' 'LinkedIn' 'Facebook' 'SinaWeibo' 'Twitter' 'Siri' 'AppleEvents' 'Camera' 'Microphone' 'PhotosAdd' 'Reminders' 'All' 'Accessibility' 'Liverpool' 'Ubiquity' 'ShareKit' 'TencentWeibo' 'SystemPolicySysAdminFiles' 'MediaLibrary' 'SystemPolicyDeveloperFiles')

for service in "${SERVICES[@]}"; do
    if /usr/bin/tccutil reset "$service"; then
        echo "Reset TCC settings for $service"
    else
        echo "Could not reset TCC settings for $service"
    fi
done
