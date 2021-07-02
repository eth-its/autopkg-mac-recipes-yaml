#!/bin/bash
## ETH_Templates_MSOffice postinstall script - sets the version

## write the version to a defaults file
echo "Writing version to ch.ethz.id.ETHTemplatesMSOffice preferences"
/usr/bin/defaults write /Library/Preferences/ch.ethz.id.ETHTemplatesMSOffice version -string "%version%"
