#!/bin/zsh
# shellcheck shell=bash

#######################################################################
#
# Uninstall Cisco Secure Client
#
# Note: versions of Cisco Secure Client which include a System Extension
# cannot be uninstalled without an admin user providing credentials
# via a GUI prompt.
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

app_name="Cisco Secure Client"

# quit the app if running
silent_app_quit "$app_name"

# remove Cisco Secure Client socket extension
# originally from Tyler in MacAdmins Slack:
# https://macadmins.slack.com/archives/CK38R7KPS/p1645729119584389?thread_ts=1645726163.719389&cid=CK38R7KPS

user=$(/usr/bin/stat -f %Su "/dev/console")
ACSOCKEXTACTIVE=$(/usr/bin/systemextensionsctl list | grep acsockext)

if [ ! "x${ACSOCKEXTACTIVE}" = "x" ]; then
    echo "Deactivating network extension acsockext"
    # Need to run as logged in user, as user needs to authorize the extension deactivation.
    if /usr/bin/su $user -c '/Applications/Cisco/Cisco\ Secure\ Client\ -\ Socket\ Filter.app/Contents/MacOS/Cisco\ Secure\ Client\ -\ Socket\ Filter -deactivateExt' ; then
        echo "Network extension acsockext deactivated"
        # Remove the network extension KDF app.
        if /bin/rm -Rf "/Applications/Cisco/Cisco Secure Client - Socket Filter.app" ; then
            echo "Cisco Secure Client Socket Filter deleted"
        else
            echo "ERROR: Cisco Secure Client Socket Filter not deleted"
        fi
    else
        echo "ERROR: Network extension acsockext not deactivated"
    fi
else
    echo "Skip deactivating of network extension acsockext"
fi

# Run Cisco's built-in uninstaller
# Taken from http://kb.mit.edu/confluence/display/mitcontrib/Cisco+Anyconnect+Manual+uninstall+Mac+OS
echo "Removing application: ${app_name}"

uninstaller_original="/opt/cisco/vpn/bin/vpn_uninstall.sh"
uninstaller_anyconnect="/opt/cisco/anyconnect/bin/anyconnect_uninstall.sh"
uninstaller_secureclient="/opt/cisco/secureclient/bin/cisco_secure_client_uninstall.sh"
if [[ -f "$uninstaller_secureclient" ]]; then 
	"$uninstaller_secureclient"
fi
if [[ -f "$uninstaller_anyconnect" ]]; then 
	"$uninstaller_anyconnect"
fi
if [[ -f "$uninstaller_original" ]]; then 
	"$uninstaller_original"
fi

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=com.cisco.pkg.anyconnect.vpn && $pkgutilcmd --forget com.cisco.pkg.anyconnect.vpn
$pkgutilcmd --pkgs=ch.ethz.id.pkg.CiscoAnyConnect && $pkgutilcmd --forget ch.ethz.id.pkg.CiscoAnyConnect

echo "${app_name} removal complete!"
