#!/bin/bash

#######################################################################
#
# Remove R.app Script for Jamf Pro
# includes elements from https://gist.github.com/ryangatchalian912/b87813937d47b75c922e825177f83a61
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

app_name="R"

# quit the app if running
silent_app_quit "$app_name"

# Now remove the app
echo "Removing application: ${check_app_name}"

app_to_trash="/Applications/$check_app_name"

# 1. Remove the application
if [[ -d "${app_to_trash}" ]]; then
    if /bin/rm -Rf "${app_to_trash}"; then
        echo "$app_name deleted successfully"
    else
        echo "$app_name failed to delete"
        exit 1
    fi
else
    echo "${app_to_trash} not found"
fi

/usr/sbin/pkgutil --pkgs=org.R-project.R.GUI.pkg && /usr/sbin/pkgutil --forget org.R-project.R.GUI.pkg
/usr/sbin/pkgutil --pkgs=org.r-project.R.el-capitan.GUI.pkg && /usr/sbin/pkgutil --forget org.r-project.R.el-capitan.GUI.pkg

# 2. Framework
echo "Removing /Library/Frameworks/R.framework"

# Verify that core R package bom exists. Otherwise, don't do anything.
if [ -e /var/db/receipts/org.R-project.R.fw.pkg.bom ]; then
    # Loop through all the files in the bom.
    echo '>>> Removing bom files from org.R-project.R.fw.pkg.bom...'
    lsbom -f -l -s -pf /var/db/receipts/org.R-project.R.fw.pkg.bom | while read i; do
        # Remove each file listed in the bom.
        rm -v /Library/Frameworks/${i#./}
    done
fi
/usr/sbin/pkgutil --pkgs=org.R-project.R.fw.pkg && /usr/sbin/pkgutil --forget org.R-project.R.fw.pkg
/usr/sbin/pkgutil --pkgs=org.r-project.R.el-capitan.GUI.pkg && /usr/sbin/pkgutil --forget org.r-project.R.el-capitan.GUI.pkg

# 3. tcltk
if [ -e /var/db/receipts/org.r-project.x86_64.tcltk.bom ]; then
    # Loop through all the files in the bom.
    echo '>>> Removing bom files from org.r-project.x86_64.tcltk.bom...'
    lsbom -f -l -s -pf /var/db/receipts/org.r-project.x86_64.tcltk.bom | while read i; do
        # Remove each file listed in the bom.
        rm -v /${i#./}
    done
fi
/usr/sbin/pkgutil --pkgs=org.r-project.x86_64.tcltk.x11 && /usr/sbin/pkgutil --forget org.r-project.x86_64.tcltk.x11

# 4. TeXInfo
if [ -e /var/db/receipts/org.r-project.x86_64.texinfo.bom ]; then
    # Loop through all the files in the bom.
    echo '>>> Removing bom files from org.r-project.x86_64.texinfo.bom...'
    lsbom -f -l -s -pf /var/db/receipts/org.r-project.x86_64.texinfo.bom | while read i; do
        # Remove each file listed in the bom.
        rm -v /${i#./}
    done
fi
/usr/sbin/pkgutil --pkgs=org.r-project.x86_64.texinfo && /usr/sbin/pkgutil --forget org.r-project.x86_64.texinfo

# 5. remove other files
# Remove files and directories related to R for Mac OSX.
echo "Removing any remaining R files and directories..."
rm -rf /Library/Frameworks/R.framework ||:
rm -rf /usr/local/lib/itcl* ||:
rm -rf /usr/local/lib/sqlite* ||:
rm -rf /usr/local/lib/thread* ||:
rm -rf /usr/local/lib/tcl* ||:
rm -rf /usr/local/lib/tdbc* ||:
rm -rf /usr/local/lib/tk* ||:
rm -rf /usr/local/lib/Tk* ||:
rm -rf /usr/local/share/texinfo ||:
rm -rf /usr/local/bin/{makeinfo,R,Rscript} ||:
rm -rf /private/var/folders/h_/y0zznsx52311nbq4t46y3chm0000gn/C/org.R-project.R ||:
rm -rf /var/db/receipts/org.R-project.R.* ||:
rm -rf /var/db/receipts/org.r-project.x86_64.* ||:

echo "$app_name deletion complete"
