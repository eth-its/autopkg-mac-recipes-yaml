#!/bin/zsh

sudo bash -c 'cat > /Library/Management/ETH/SupportApp/status_update.zsh << "EOF"
#!/bin/zsh

# Support App Extension - Status update (Runs every time the Support app is opened)

# Support App preference plist
preference_file_location="/Library/Preferences/nl.root3.support.plist"

# Set Variables
SupportGroup=$(defaults read /Library/Managed\ Preferences/nl.root3.support SupportGroup)
serialNumber=$(system_profiler SPHardwareDataType | awk -F": " "/Serial Number/ {print \$2}")

# Set Values of Support App Content
defaults write "${preference_file_location}" FooterText -string "**This Mac is managed by $SupportGroup**\\n---------------------------------\\nSerial Number: $serialNumber"

if [ -d "/Applications/Privileges.app" ]; then
    defaults write "${preference_file_location}" SecondRowTitleRight -string "Admin Rights"
	defaults write "${preference_file_location}" SecondRowSymbolRight -string "lock.fill"
	defaults write "${preference_file_location}" SecondRowSubtitleRight -string "Add or Remove"
else
    defaults write "${preference_file_location}" SecondRowTitleRight -string "Check-In"
    defaults write "${preference_file_location}" SecondRowSubtitleRight -string "Check-In"
	defaults write "${preference_file_location}" SecondRowSymbolRight -string "arrow.trianglehead.2.clockwise"
fi

EOF

cat > /Library/Management/ETH/SupportApp/SecondRowRight.zsh << "EOF"
#!/bin/zsh

#########################################################
# Support App config SecondRowRight					    #
# created by Philippe Scholl                            #
# version 1.1										    #
# copyright by Mac Product Center                       #
# Date: 25.10.2024                                      #
#########################################################

# Support App preference plist
preference_file_location="/Library/Preferences/nl.root3.support.plist"


if [ -d "/Applications/Privileges.app" ]; then
    open -b corp.sap.privileges
else
	defaults write "${preference_file_location}" SecondRowSymbolRight -string "progress.indicator"
    defaults write "${preference_file_location}" SecondRowTitleRight -string "Please wait..."
    defaults write "${preference_file_location}" SecondRowSubtitleRight -string "Please wait..."
    
    jamf policy
    
    sleep 2
    
    defaults write "${preference_file_location}" SecondRowSymbolRight -string "arrow.trianglehead.2.clockwise"
    defaults write "${preference_file_location}" SecondRowTitleRight -string "Check-In"
    defaults write "${preference_file_location}" SecondRowSubtitleRight -string "Check-In"
fi

EOF
'
chmod 755 /Library/Management/ETH/SupportApp/status_update.zsh
chmod 755 /Library/Management/ETH/SupportApp/SecondRowRight.zsh

# Enable PrivilegedHelperTool
/Applications/Support.app/Contents/Resources/install_privileged_helper_tool.zsh