#!/bin/bash

#######################################################################
#
# Uninstall Adobe Acrobat Reader (DC)
#
#######################################################################

function silent_app_quit() {
    # silently kill the application.
    # add .app to end of string if not supplied
    app_name="${app_name/\.app/}"            # remove any .app
    check_app_name="${app_name/\(/\\(}"       # escape any brackets for the pgrep
    check_app_name="${check_app_name/\)/\\)}"  # escape any brackets for the pgrep
    check_app_name="${check_app_name}.app"     # add the .app back
    echo "Checking if ${check_app_name} is open"
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

# quit the app if running
app_name="Adobe Acrobat"
silent_app_quit "$app_name"

# now remove everything that was in the package payload
/bin/rm -rf "/Applications/Adobe Acrobat DC" ||:



# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=com.adobe.acrobat.DC.sca.config.application.1.pkg.MUI && $pkgutilcmd --forget com.adobe.acrobat.DC.sca.config.application.1.pkg.MUI
$pkgutilcmd --pkgs=com.adobe.acrobat.DC.scamini.app.pkg.MUI && $pkgutilcmd --forget com.adobe.acrobat.DC.scamini.app.pkg.MUI
$pkgutilcmd --pkgs=com.adobe.acrobat.DC.scamini.appsupport.pkg.MU && $pkgutilcmd --forget com.adobe.acrobat.DC.scamini.appsupport.pkg.MU


echo "${app_name} removal complete!"
