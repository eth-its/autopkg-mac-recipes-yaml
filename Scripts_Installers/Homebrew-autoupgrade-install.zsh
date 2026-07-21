#!/bin/zsh

## write automatic updater script to disk
if [ ! -d /Library/Management/ETHZ/Scripts ] ; then mkdir /Library/Management/ETHZ/Scripts ; fi
cat >/Library/Management/ETHZ/Scripts/homebrew-updater.sh <<'EOT'
#!/bin/zsh
sleep 10 #in case we're launched by bootup, allow 10 seconds for system to establish internet connection
if [ -f /opt/homebrew/bin/brew ] ; then homebrew_binary=/opt/homebrew/bin/brew ; else homebrew_binary=/usr/local/bin/brew ; fi 
homebrew_user=$(stat -f%u $homebrew_binary)
if $homebrew_binary --version >/dev/null 2>&1; then 
echo "brew found - starting upgrade run at $(date)" 
sudo -u \#$homebrew_user  $homebrew_binary update
sudo -u \#$homebrew_user  $homebrew_binary upgrade
sudo -u \#$homebrew_user  $homebrew_binary upgrade --cask
sudo -u \#$homebrew_user  $homebrew_binary cleanup
echo "brew update complete at $(date)"
else
echo "homebrew not installed/not in path, aborting at $(date)"
fi
EOT
chmod 755 /Library/Management/ETHZ/Scripts/homebrew-updater.sh

## drop launchd to autoupdate every midday, and at every boot
cat >/Library/LaunchDaemons/ch.ethz.homebrew-autoupgrade.plist <<EOT2
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>ch.ethz.brew-autoupgrade</string>
    <key>RunAtLoad</key>
    <true/>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>12</integer>
        <key>Minute</key>
        <integer>00</integer>
    </dict>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/zsh</string>
		<string>/Library/Management/ETHZ/Scripts/homebrew-updater.sh</string>
	</array>
    <key>StandardOutPath</key>
    <string>/Library/Logs/ch.ethz.brew-autoupgrade.log</string>
    <key>StandardErrorPath></key>
    <string>/Library/Logs/ch.ethz.brew-autoupgrade.log</string>
</dict>
</plist>
EOT2
chown root:wheel /Library/LaunchDaemons/ch.ethz.homebrew-autoupgrade.plist
chmod 644 /Library/LaunchDaemons/ch.ethz.homebrew-autoupgrade.plist
launchctl bootout system /Library/LaunchDaemons/ch.ethz.homebrew-autoupgrade.plist
launchctl bootstrap system /Library/LaunchDaemons/ch.ethz.homebrew-autoupgrade.plist
