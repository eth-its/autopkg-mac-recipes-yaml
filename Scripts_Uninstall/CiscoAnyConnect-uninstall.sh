#!/bin/bash

#######################################################################
#
# Uninstall Cisco AnyConnect
#
# Note: versions of AnyConnect which include a System Extension
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

app_name="Cisco AnyConnect Secure Mobility Client"

# quit the app if running
silent_app_quit "$app_name"

# Run Cisco's built-in uninstaller
# Taken from http://kb.mit.edu/confluence/display/mitcontrib/Cisco+Anyconnect+Manual+uninstall+Mac+OS
echo "Removing application: ${app_name}"

cisco_uninstaller="/opt/cisco/vpn/bin/vpn_uninstall.sh"
cisco_uninstaller_new="/opt/cisco/anyconnect/bin/anyconnect_uninstall.sh"
if [[ -f "$cisco_uninstaller" ]]; then 
	"$cisco_uninstaller"
elif [[ -f "$cisco_uninstaller_new" ]]; then 
	"$cisco_uninstaller_new"
else
	echo "no Cisco uninstaller found"
fi

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=com.cisco.pkg.anyconnect.vpn && $pkgutilcmd --forget com.cisco.pkg.anyconnect.vpn
$pkgutilcmd --pkgs=ch.ethz.id.pkg.CiscoAnyConnect && $pkgutilcmd --forget ch.ethz.id.pkg.CiscoAnyConnect

echo "${app_name} removal complete!"
