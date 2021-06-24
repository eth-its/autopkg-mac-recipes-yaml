#!/bin/bash

:<<DOC
Enable system wide automatic updates for Google Chrome.

Adapted for bash by Graham Pugh.

Based on chrome-enable-autoupdates.py by Hannes Juutilainen, hjuutilainen@mac.com

Working only for Chrome versions 80 or higher 
DOC

chrome_path="/Applications/Google Chrome.app"
info_plist_path="$chrome_path/Contents/Info.plist"
tag_path=info_plist_path
tag_key="KSChannelID"
brand_path="/Library/Google/Google Chrome Brand.plist"
brand_key="KSBrandID"
version_path=info_plist_path
version_key="KSVersion"

# exit if Chrome not installed
if [[ ! -d "$chrome_path" ]]; then
    echo "ERROR: $chrome_path not found"
    exit 1
fi

# get KSUpdateURL and KSProductID from Chrome Info.plist
chrome_update_url=$(/usr/bin/defaults read "$info_plist_path" KSUpdateURL)
chrome_version=$(/usr/bin/defaults read "$info_plist_path" CFBundleShortVersionString)
chrome_product_id=$(/usr/bin/defaults read "$info_plist_path" KSProductID)

# Keystone registration path (v76 or higher only)
keystone_registration_framework_path="$chrome_path/Contents/Frameworks/Google Chrome Framework.framework/Frameworks/KeystoneRegistration.framework/Versions/Current"

# install the current framework (v80 or higher only)
install_script="$keystone_registration_framework_path/Helpers/ksinstall"
keystone_payload="$keystone_registration_framework_path/Resources/Keystone.tbz"

if [[ -f "$install_script" && -f "$keystone_payload" ]]; then
    echo "Running ksinstall..."
    if ! "$install_script" --install "$keystone_payload" --force 2>/dev/null ; then
        echo "WARNING: Keystone install returned an error (proceeding anyway)"
    fi
    echo "Keystone installed"
else
    echo "Error: KeystoneRegistration.framework not found"
fi

# register Chrome with Keystone
ksadmin="/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/MacOS/ksadmin"

echo "Running ksadmin..."
if [[ -f "$ksadmin" ]]; then
    if "$ksadmin" \
    --register \
    --productid "$chrome_product_id" \
    --version "$chrome_version" \
    --xcpath "$chrome_path" \
    --url "$chrome_update_url" \
    --tag-path "$tag_path" \
    --tag-key "$tag_key" \
    --brand-path "$brand_path" \
    --brand-key "$brand_key" \
    --version-path "$version_path" \
    --version-key "$version_key"
    then
        echo "Registered Chrome with Keystone"
    else
        echo "Error: Failed to register Chrome with Keystone"
    fi
else
    echo "Error: $ksadmin doesn't exist"   
fi
