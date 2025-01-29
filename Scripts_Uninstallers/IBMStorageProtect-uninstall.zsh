#!/bin/zsh
# shellcheck shell=bash

# Uninstall IBM Storage Protect

appName="IBM Storage Protect"

function silent_app_quit() {
    # silently kill the application.
    appName="$1"
    if [[ $(pgrep -ix "$appName") ]]; then
    	echo "Closing $appName"
    	/usr/bin/osascript -e "quit app \"$appName\""
    	sleep 1

    	# double-check
    	countUp=0
    	while [[ $countUp -le 10 ]]; do
    		if [[ -z $(pgrep -ix "$appName") ]]; then
    			echo "$appName closed."
    			break
    		else
    			let countUp=$countUp+1
    			sleep 1
    		fi
    	done
        if [[ $(pgrep -x "$appName") ]]; then
    	    echo "$appName failed to quit - killing."
    	    /usr/bin/pkill "$appName"
        fi
    fi
}
# quit the app if running
silent_app_quit "$appName"

echo "Removing application: ${appName}"

/bin/rm -rf "/Applications/IBM Storage Protect" ||:
/bin/rm -rf "/Library/Application Support/tivoli" ||:
/bin/rm -f "/usr/bin/dsmc" "/usr/bin/dsmcad" "/usr/bin/dsmadmc" "/usr/bin/dsmtrace" "/usr/bin/dsmagent" "/usr/lib/libxmlutil-6.2.0.dylib" "/usr/lib/libtsm620xerces-c1_6_0.dylib" ||:

fm_receipts="com.ibm.tivoli.tsm.baclient
com.ibm.tivoli.tsm.baclientjava"

# Loop through the remaining parameters
pkgutilcmd="/usr/sbin/pkgutil"
while read -r receipt; do
	$pkgutilcmd --pkgs=${receipt} && $pkgutilcmd --forget ${receipt}
done <<< "${receipts}"

echo "${appName} removal complete!"
