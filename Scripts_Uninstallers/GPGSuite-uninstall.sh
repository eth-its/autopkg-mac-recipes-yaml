#!/bin/bash

: <<END 
This script is adapted from "uninstall.sh", taken from the GPG Suite uninstaller application, available at https://gpgtools.tenderapp.com/kb/faq/uninstall-gpg-suite
END

if [[ $UID -ne 0 ]] ;then
	echo "uninstall must be run as root!" >&2
	exit 1
fi


restartMail=0
if pgrep -q -u "$USER" -f "Mail.app/Contents/MacOS/Mail"; then
	restartMail=1
fi

osascript -e '
try
quit application id "com.apple.mail"
end try
try
quit application id "org.gpgtools.gpgkeychainaccess"
end try
try
quit application id "org.gpgtools.gpgkeychain"
end try
try
quit application id "org.gpgtools.gpgservices"
end try
try
quit application id "com.apple.systempreferences"
end try'

function rmv () {
	rm -f "$@"
}

# Kill the gpg processes
killall -kill gpg-agent dirmngr gpg gpg2

sudo -nu "$USER" launchctl remove org.gpgtools.Libmacgpg.xpc
sudo -nu "$USER" launchctl remove org.gpgtools.gpgmail.patch-uuid-user
sudo -nu "$USER" launchctl remove org.gpgtools.gpgmail.updater
sudo -nu "$USER" launchctl remove org.gpgtools.macgpg2.fix
sudo -nu "$USER" launchctl remove org.gpgtools.macgpg2.shutdown-gpg-agent
sudo -nu "$USER" launchctl remove org.gpgtools.macgpg2.updater
sudo -nu "$USER" launchctl remove org.gpgtools.macgpg2.gpg-agent
sudo -nu "$USER" launchctl remove org.gpgtools.updater



rmv -r /Library/Services/GPGServices.service "$HOME"/Library/Services/GPGServices.service
rmv -r /Library/Mail/Bundles/GPGMail.mailbundle "$HOME"/Library/Mail/Bundles/GPGMail.mailbundle /Network/Library/Mail/Bundles/GPGMail.mailbundle
rmv -r /Library/Mail/Bundles/GPGMailLoader*.mailbundle
rmv -r /usr/local/MacGPG2
rmv -r /private/etc/paths.d/MacGPG2
rmv -r /private/etc/manpaths.d/MacGPG2
rmv -r /private/tmp/gpg-agent

[[ "$(readlink /usr/local/bin/gpg2)" =~ MacGPG2 ]] && rmv /usr/local/bin/gpg2
[[ "$(readlink /usr/local/bin/gpg)" =~ MacGPG2 ]] && rmv /usr/local/bin/gpg
[[ "$(readlink /usr/local/bin/gpg-agent)" =~ MacGPG2 ]] && rmv /usr/local/bin/gpg-agent
rmv -r /Library/PreferencePanes/GPGPreferences.prefPane "$HOME"/Library/PreferencePanes/GPGPreferences.prefPane

gkaLocation=$(mdfind -onlyin /Applications "kMDItemCFBundleIdentifier = org.gpgtools.gpgkeychainaccess" | head -1)
gkaLocation=${gkaLocation:-/Applications/GPG Keychain Access.app}
[[ "$gkaLocation" != "" ]] && rmv -r "$gkaLocation"

# GPG Keychain Access has sinced been renamed to GPG Keychain, so let's make
# sure that GPG Keychain is removed as well. 
gkLocation=$(mdfind -onlyin /Applications "kMDItemCFBundleIdentifier = org.gpgtools.gpgkeychain" | head -1)
gkLocation=${gkLocation:-/Applications/GPG Keychain.app}
[[ "$gkLocation" != "" ]] && rmv -r "$gkLocation"


rmv /Library/LaunchDaemons/org.gpgtools.*
rmv /Library/LaunchAgents/org.gpgtools.*

rmv "$HOME/Library/LaunchAgents/org.gpgtools."*
rmv "$HOME/Library/Preferences/org.gpgtools."*
rmv "$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/org.gpgtools."*
rmv -r "/Library/Application Support/GPGTools" "$HOME/Library/Application Support/GPGTools"
rmv -r "/Library/Frameworks/Libmacgpg.framework" "$HOME/Library/Frameworks/Libmacgpg.framework" "$HOME/Containers/com.apple.mail/Data/Library/Frameworks/Libmacgpg.framework"

pkgutil --regexp --forget 'org\.gpgtools\..*'


if [[ $restartMail -eq 1 ]]; then
	sudo -nu "$USER" open -gb com.apple.mail
fi 
