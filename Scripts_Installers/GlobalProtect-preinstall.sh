#!/bin/bash

# https://community.jamf.com/t5/jamf-pro/update-plist-of-global-protect/td-p/221125
# Parameter 4: VPN portal address

portal="$4"

plistBuddy='/usr/libexec/PlistBuddy'
GPplistFile='/Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist'

if [[ -f ${GPplistFile} ]]; then
  echo "Removing existing GlobalProtect prefs file"
  rm -f ${GPplistFile}
fi

${plistBuddy} -c "print : 'Palo Alto Networks':'GlobalProtect':'PanSetup':'Portal'" ${GPplistFile}

${plistBuddy} -c "add :'Palo Alto Networks' dict" ${GPplistFile}
${plistBuddy} -c "add :'Palo Alto Networks':'GlobalProtect' dict" ${GPplistFile}
${plistBuddy} -c "add :'Palo Alto Networks':'GlobalProtect':'PanSetup' dict" ${GPplistFile}
${plistBuddy} -c "add :'Palo Alto Networks':'GlobalProtect':'PanSetup':'Portal' string '${portal}'" ${GPplistFile}
${plistBuddy} -c "add :'Palo Alto Networks':'GlobalProtect':'PanSetup':'Prelogon' integer 1" ${GPplistFile}