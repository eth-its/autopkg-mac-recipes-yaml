#!/bin/zsh
# shellcheck shell=bash

## XQuartz uninstaller
## details from https://discussions.apple.com/thread/4162096

echo "** Uninstalling XQuartz **"


# remove launch agent and daemon
# < 2.8
[[ -f /Library/LaunchAgents/org.macosforge.xquartz.startx.plist ]] && launchctl unload /Library/LaunchAgents/org.macosforge.xquartz.startx.plist
# 2.8+
[[ -f /Library/LaunchAgents/org.xquartz.startx.plist ]] && launchctl unload /Library/LaunchAgents/org.xquartz.startx.plist
echo ".. XQuartz launch agent removed"

# < 2.8
[[ -f /Library/LaunchDaemons/org.macosforge.xquartz.privileged_startx.plist ]] && launchctl unload /Library/LaunchDaemons/org.macosforge.xquartz.privileged_startx.plist
# 2.8+
[[ -f /Library/LaunchDaemons/org.xquartz.privileged_startx.plist ]] && launchctl unload /Library/LaunchDaemons/org.xquartz.privileged_startx.plist
echo ".. XQuartz launch daemon removed"

# remove files
/bin/rm -rf /opt/X11* ||:
/bin/rm -rf /Library/Launch*/org.macosforge.xquartz.* ||:
/bin/rm -rf /Library/Launch*/org.xquartz.* ||:
/bin/rm -rf /Applications/Utilities/XQuartz.app ||:
/bin/rm -rf /etc/*paths.d/*XQuartz ||:
echo ".. XQuartz files removed"

# forget package
/usr/sbin/pkgutil --pkgs=org.macosforge.xquartz.pkg && /usr/sbin/pkgutil --forget org.macosforge.xquartz.pkg
/usr/sbin/pkgutil --pkgs=org.xquartz.pkg && /usr/sbin/pkgutil --forget org.xquartz.pkg

echo ".. XQuartz package forgotten"

echo "** XQuartz removal complete**"
