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

# ensure updates are checked even when Chrome is not open
# source https://babodee.wordpress.com/2020/06/16/managing-google-chrome-auto-updates/

# current logged-in user's short name
current_user=$(/bin/ls -la /dev/console | /usr/bin/cut -d " " -f 4)

uid=$(id -u "$current_user")
echo "Current user is $current_user"

launchagent="/Library/LaunchAgents/com.github.eth-its.google.softwareupdatecheck"

# reset any old version
if [[ -f "$launchagent" ]]; then
    if /bin/launchctl disable "user/$uid/com.github.eth-its.google.softwareupdatecheck"; then
        echo "LaunchAgent successfully disabled"
    else
        echo "LaunchAgent was not disabled."
    fi
    if sudo -u "$current_user" -i /bin/launchctl unload -F "$launchagent"; then
        echo "LaunchAgent successfully unloaded"
    else
        echo "LaunchAgent was not unloaded."
    fi

    if /bin/rm "$launchagent"; then
        echo "LaunchAgent successfully deleted"
    else
        echo "LaunchAgent was not deleted."
    fi
fi

cat > "$launchagent" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Label</key>
<string>com.github.eth-its.google.softwareupdatecheck</string>
<key>LimitLoadToSessionType</key>
<string>Aqua</string>
<key>ProgramArguments</key>
<array>
<string>/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/GoogleSoftwareUpdateAgent.app/Contents/MacOS/GoogleSoftwareUpdateAgent</string>
<string>-runMode</string>
<string>oneshot</string>
<string>-userInitiated</string>
<string>YES</string>
<string>"$@"</string>
</array>
<key>RunAtLoad</key>
<true/>
<key>StartInterval</key>
<integer>21600</integer>
</dict>
</plist>
EOF

# adjust permissions correctly then load.
/usr/sbin/chown root:wheel "$launchagent"
/bin/chmod 644 "$launchagent"

if sudo -u "$current_user" -i /bin/launchctl load -F "$launchagent"; then
    echo "LaunchAgent successfully loaded"
else
    echo "LaunchAgent was not loaded."
fi

if sudo -u "$current_user" -i /bin/launchctl enable "user/$uid/com.github.eth-its.google.softwareupdatecheck"; then
    echo "LaunchAgent successfully enabled"
else
    echo "LaunchAgent was not enabled."
fi


# adjust permissions for application.
chown -R "$(stat -f%Su /dev/console):staff" "/Applications/Google Chrome.app"
