#!/bin/zsh
#built into Homebrew-uninstall.sh, this is just here in case autoupgrade should become standalone/optional
rm -f /Library/Management/ETHZ/Scripts/homebrew-updater.sh
launchctl bootout system /Library/LaunchDaemons/ch.ethz.homebrew-autoupgrade.plist
rm -f /Library/LaunchDaemons/ch.ethz.homebrew-autoupgrade.plist
tail -n 300 /Library/Logs/ch.ethz.brew-autoupgrade.log>/Library/Logs/ch.ethz.brew-autoupgrade.log.tmp
echo "\nUNINSTALLED AT $(date)\n\n">>/Library/Logs/ch.ethz.brew-autoupgrade.log.tmp
mv /Library/Logs/ch.ethz.brew-autoupgrade.log.tmp /Library/Logs/ch.ethz.brew-autoupgrade.log
