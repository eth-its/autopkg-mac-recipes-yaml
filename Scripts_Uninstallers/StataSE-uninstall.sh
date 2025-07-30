#!/bin/bash

#######################################################################
#
# Uninstall StataSE
#
# Requires these Parameters
# Parameter 4: MAJOR_VERSION (e.g. 15)
#
#######################################################################

# StataSE version
if [[ $4 ]]; then
    statase_version=$4
elif [[ $1 == "-v" && $2 ]]; then
    statase_version=$2
else
    echo "Error: No StataSE version specified!"
    exit 1
fi

function silent_app_quit() {
    # silently kill the application.
    # add .app to end of string if not supplied
    app_name="${app_name/\.app/}"            # remove any .app
    check_app_name="${app_name/\(/\\(}"       # escape any brackets for the pgrep
    check_app_name="${check_app_name/\)/\\)}"  # escape any brackets for the pgrep
    check_app_name="${check_app_name}.app"     # add the .app back
    if pgrep -f "/${check_app_name}" ; then
        echo "Closing $check_app_name"
        /usr/bin/osascript -e "quit app \"$app_name\"" &
        sleep 1

        # double-check
        n=0
        while [[ $n -lt 10 ]]; do
            if pgrep -f "/$check_app_name" ; then
                (( n=n+1 ))
                sleep 1
				echo "Graceful close attempt # $n"
            else
                echo "$app_name closed."
                break
            fi
        done
        if pgrep -f "/$check_app_name" ; then
            echo "$check_app_name failed to quit - killing."
            /usr/bin/pkill -f "/$check_app_name"
        fi
    fi
}

# Inputted variables
app_name="StataSE"

if [[ -d "/Applications/Stata ${statase_version}" ]]; then
    app_dir="/Applications/Stata ${statase_version}"
elif [[ -d "/Applications/Stata" ]]; then
    installed_version=$(/usr/bin/defaults read /Applications/Stata/StataSE.app/Contents/Info.plist CFBundleShortVersionString | cut -d. -f 1)
    if [[ "$installed_version" == "$statase_version" ]]; then
        app_dir="/Applications/Stata"
    else
        echo "StataSE ${statase_version} not found, nothing to do."
    fi
else
    echo "Older StataSE ${statase_version} not found, looking for newer versions now..."
    exit
fi
if [[ -d "/Applications/StataNow ${statase_version}" ]]; then
    app_dir="/Applications/Stata ${statase_version}"
elif [[ -d "/Applications/StataNow" ]]; then
    installed_version=$(/usr/bin/defaults read /Applications/StataNow/StataSE.app/Contents/Info.plist CFBundleShortVersionString | cut -d. -f 1)
    if [[ "$installed_version" == "$statase_version" ]]; then
        app_dir="/Applications/StataNow"
    else
        echo "StataSE ${statase_version} not found, nothing to do."
        exit
    fi
else
    echo "StataSE ${statase_version} not found, nothing to do."
    exit
fi

# quit the app if running
silent_app_quit

# Now remove the app
echo "Removing application: ${app_dir}"

# Manual list of files to remove
rm -rf "$app_dir" ||:

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"
$pkgutilcmd --pkgs=com.stata.pkg.stata${statase_version}.StataBase && $pkgutilcmd --forget com.stata.pkg.stata${statase_version}.StataBase ||:
$pkgutilcmd --pkgs=com.stata.pkg.stata${statase_version}.StataSE && $pkgutilcmd --forget com.stata.pkg.stata${statase_version}.StataSE ||:
$pkgutilcmd --pkgs=ch.ethz.id.pkg.StataSEInstaller && $pkgutilcmd --forget ch.ethz.id.pkg.StataSEInstaller ||:
$pkgutilcmd --pkgs=ch.ethz.id.pkg.StataSEInstaller && $pkgutilcmd --forget ch.ethz.id.pkg.StataSE${statase_version}Installer ||:
