#!/bin/bash
## ETH_Templates_MSOffice postinstall script
## Supports Office 2016, 2019 and 365

templates_folder="/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized"

## change permissions
echo "Changing permissions on imported templates"
/bin/chmod -R 644 "$templates_folder"/*.potx "$templates_folder"/*.pdf "$templates_folder"/*/*.dotx


# delete the __MACOSX artifact from the zip files
if [[ -d "$templates_folder/__MACOSX" ]]; then 
    echo "Removing __MACOSX folder"
    rm -rf "$templates_folder/__MACOSX" ||:
fi

## write the version to a defaults file
echo "Writing version to ch.ethz.id.ETHTemplatesMSOffice preferences"
/usr/bin/defaults write /Library/Preferences/ch.ethz.id.ETHTemplatesMSOffice version -string "%version%"
