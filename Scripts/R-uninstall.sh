#!/bin/bash

#######################################################################
#
# Remove R.app Script for Jamf Pro
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

app_name="R.app"

# quit the app if running
silent_app_quit "$app_name"

# Now remove the app
echo "Removing application: ${app_name}"

app_to_trash="/Applications/$app_name"

# Remove the application
/bin/rm -Rf "${app_to_trash}"

echo "Checking if $app_name is actually deleted..."
if [[ -d "${app_to_trash}" ]]; then
    echo "$app_name failed to delete"
else
    echo "$app_name deleted successfully"
fi

# Remove other components
echo "Removing /Library/Frameworks/R.framework"
rm -Rf /Library/Frameworks/R.framework
echo "Removing symlinks in /usr/local/bin"
rm /usr/local/bin/R /usr/local/bin/Rscript

# Removing tcltk and texinfo packages requires munki's removepackages
munki_path="/usr/local/munki"
if [[ ! -f "${munki_path}/removepackages" ]]; then
    echo "${munki_path}/removepackages binary not installed! Installing now."
    /usr/local/bin/jamf policy -event ETHPkgUninstallerTool-install
fi

# Check again
if [[ ! -f "${munki_path}/removepackages" ]]; then
    echo "${munki_path}/removepackages binary not installed! Cannot continue."
    exit 1
fi

# Try to Forget the packages if we can find a match
# Loop through the remaining parameters
for package in org.R-project.R.GUI.pkg org.R-project.R.fw.pkg org.r-project.R.el-capitan.fw.pkg org.r-project.R.el-capitan.GUI.pkg org.r-project.x86_64.tcltk.x11 org.r-project.x86_64.texinfo; do
	echo "Removing package ${package}..."
	${munki_path}/removepackages -f ${package} | tr '\r' ';' | sed -e 's/^.*;//'
done

echo "$app_name deletion complete"
