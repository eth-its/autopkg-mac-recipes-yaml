#!/bin/bash
## ETH_Templates_MSOffice postinstall script
## Supports Office 2016, 2019 and 365

# delete the __MACOSX artifact from the zip files
if [[ -d "/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized/__MACOSX" ]]; then 
    rm -rf "/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized/__MACOSX" ||:
fi

## write the version to a defaults file
/usr/bin/defaults write /Library/Preferences/ch.ethz.id.ETHTemplatesMSOffice version -string "%version%"
