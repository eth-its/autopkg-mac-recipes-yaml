#!/bin/bash

#######################################################################
#
# Uninstall Citrix Workspace
#
#######################################################################

function silent_app_quit() {
    # silently kill the application.
    # add .app to end of string if not supplied
    app_name="${app_name/\.app/}"            # remove any .app
    check_app_name="${app_name/\(/\\(}"       # escape any brackets for the pgrep
    check_app_name="${check_app_name/\)/\\)}"  # escape any brackets for the pgrep
    check_app_name="${check_app_name}.app"     # add the .app back
    if pgrep -f "/${check_app_name}" ; then
        echo "Closing $app_name"
        /usr/bin/osascript -e "quit app \"$app_name\"" &
        sleep 1

        # double-check
        n=0
        while [[ $n -lt 10 ]]; do
            if pgrep -f "$check_app_name" ; then
                (( n=n+1 ))
                sleep 1
				echo "Graceful close attempt # $n"
            else
                echo "$app_name closed."
                break
            fi
        done
        if pgrep -f "$check_app_name" ; then
            echo "$app_name failed to quit - killing."
            /usr/bin/pkill -f "$check_app_name"
        fi
    fi
}

# MAIN

app_name="Citrix Workspace"

# quit the app if running
silent_app_quit "$app_name"

## Citrix Workspace is spread all over the place. These commands are based on the contents of v21.09.1 as listed by Suspicious Package

# stop services
killall "Citrix Receiver Launcher"
killall "Citrix Workspace Launcher"
killall "Browser"
launchtl unload -wF -S Aqua "/Library/LauchAgents/com.citrix.ReceiverHelper.plist"
launchctl unload -wF "/Library/LauchDaemons/com.citrix.ctxusbd.plist"
launchtl unload -wF -S Aqua "/Library/LauchAgents/com.citrix.AuthManager_Mac.plist"
launchtl unload -wF -S Aqua "/Library/LauchAgents/com.citrix.ReceiverHelper.plist"

# FollowMeData needs to be uninstalled if present
FMD_UNINSTALLER="/Applications/Citrix/FollowMeData/Uninstall ShareFile Plug-in.app/Contents/Resources/PriviledgedTool"
if [[ -e "$FMD_UNINSTALLER" ]]; then
    "$FMD_UNINSTALLER"
fi

# remove any old items, as specified in the installer package postinstall script
/bin/rm -rf "/Library/Extensions/CitrixGUSB.kext" ||:
/bin/rm -rf "/Library/Internet Plug-Ins/CitrixICAClientPlugin.plugin" ||:
/bin/rm -rf "/Users/Shared/Citrix/Modules" ||:
/bin/rm -rf "/Applications/Citrix ICA Client" ||:
/bin/rm -rf "/Library/Receipts/Citrix ICA Client.pkg" ||:
/bin/rm -rf "/Applications/Citrix Dazzle.app" ||:
/bin/rm -rf "/Applications/Dazzle" ||:
/bin/rm -rf "/Applications/Citrix/Dazzle.app" ||:
/bin/rm -f "/Applications/Citrix/.DS_Store" ||:
/bin/rmdir "/Applications/Citrix" ||:
/bin/rm -rf "/Library/Application Support/XenDesktop Viewer.app" ||:
/bin/rm -rf "/Library/Application Support/XenApp Viewer.app" ||:
/bin/rm -rf "/Library/Application Support/Citrix" ||:
/bin/rm -rf "/Library/PreferencePanes/Citrix Online Plug-in.prefpane" ||:
/bin/rm -rf "/Library/Receipts/Install Citrix Online Plug-in.pkg" ||:
/bin/rm -f "/Library/Preferences/com.citrix.ApplicationReconnect.plist" ||:
/bin/rm -f "/Library/Preferences/com.citrix.Citrix_Dazzle.plist" ||:
/bin/rm -f "/Library/Preferences/com.citrix.DockApplication.plist" ||:
/bin/rm -f "/Library/Preferences/com.citrix.ICAClient.plist" ||:
/bin/rm -f "/Library/Preferences/com.citrix.Xen"* ||:
/bin/rm -f "/Library/Preferences/com.citrix.receiver.icaviewer.mac.plist" ||:
/bin/rm -f "/Library/Preferences/com.citrix.developer.receiver.icaviewer.mac.plist" ||:
/bin/rm -f "/Library/Preferences/com.citrix.receiver.mas.plist" ||:
/bin/rm -rf "/Applications/Citrix Receiver.app"
/bin/rm -rf "/Library/Application Support/Citrix Receiver Launcher" ||:
/bin/rm -rf "/Library/Application Support/Citrix Receiver Updater" ||:
/bin/rm -rf "/Library/Application Support/Citrix Receiver/Browser.app" ||:

# now remove everything that was in the package payload
/bin/rm -rf "/Applications/Citrix Workspace.app" ||:
/bin/rm -rf "/Library/Application Support/Citrix Browser" ||:
/bin/rm -rf "/Library/Application Support/Citrix Receiver" ||:
/bin/rm -f "/Library/LauchAgents/com.citrix.AuthManager_Mac.plist" ||:
/bin/rm -f "/Library/LauchAgents/com.citrix.ReceiverHelper.plist" ||:
/bin/rm -f "/Library/LauchAgents/com.citrix.ServiceRecords.plist" ||:
/bin/rm -f "/Library/LauchDaemons/com.citrix.ctxusbd.plist" ||:
/bin/rm -rf "/usr/local/libexec/AuthManager_Mac.app" ||:
/bin/rm -rf "/usr/local/libexec/ReceiverHelper.app" ||:
/bin/rm -rf "/usr/local/libexec/ServiceRecords.app" ||:

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=com.citrix.ICAClient && $pkgutilcmd --forget com.citrix.ICAClient
$pkgutilcmd --pkgs=ch.ethz.mac.pkg.Citrix_Receiver.ML && $pkgutilcmd --forget ch.ethz.mac.pkg.Citrix_Receiver.ML

echo "${app_name} removal complete!"
