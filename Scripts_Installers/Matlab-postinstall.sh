#!/bin/bash

#######################################################################
#
# MATLAB License Installer
#
# This script will remove the network license, which will prompt the user to activate.
# If an existing license is archived, it will retrieve it from the archive.
#
#######################################################################

# matlab version (use Jamf Parameter 4)
matlab_version="$4"

# path to folder that stores the license file (MANAGEMENT_PATH) (use Parameter 5)
mamagement_folder="$5"

# content of floating license file (use Parameter 6)
license_server="$6"
floating_license_content="
SERVER $license_server any 1965
USE_SERVER"

# desired license type (use Jamf Parameter 7)
desired_license="$7"

# name of app for trigger (e.g. R2024b_arm64 or R2024b)
trigger_name="$8"

floating_app_installed=0
node_app_installed=0

# check application is installed
if [[ -d "/Applications/MATLAB_${matlab_version}_Floating.app" ]]; then
    echo "MATLAB ${matlab_version} Floating installed"
    matlab_path="/Applications/MATLAB_${matlab_version}_Floating.app"
    floating_app_installed=1
fi
if [[ -d "/Applications/MATLAB_${matlab_version}_Node.app"  ]]; then
    echo "MATLAB ${matlab_version} Node installed"
    matlab_path="/Applications/MATLAB_${matlab_version}_Node.app"
    node_app_installed=1
fi
if [[ -d "/Applications/MATLAB_${matlab_version}.app" ]]; then
    echo "MATLAB ${matlab_version} generic app installed"
    floating_license="/Applications/MATLAB_$matlab_version.app/licenses/network.lic"
    # check for license
    if [[ -f "$floating_license" ]]; then
        # let's move the app name to Floating to make life easier
        echo "Renaming to MATLAB_${matlab_version}_Floating.app"
        matlab_path="/Applications/MATLAB_${matlab_version}_Floating.app"
        /bin/mv "/Applications/MATLAB_${matlab_version}.app" "$matlab_path"
        floating_app_installed=1
    else
        # network license not found so assume Node
        echo "Renaming to MATLAB_${matlab_version}_Node.app"
        matlab_path="/Applications/MATLAB_${matlab_version}_Node.app"
        /bin/mv "/Applications/MATLAB_${matlab_version}.app" "$matlab_path"
        node_app_installed=1
    fi
fi
if [[ $floating_app_installed = 0 && $node_app_installed = 0 ]]; then
    echo "MATLAB not installed! Running Jamf trigger"
    /usr/local/bin/jamf policy -event "MATLAB_${trigger_name}_Floating-install"
    matlab_path="/Applications/MATLAB_${matlab_version}_Floating.app"
fi

# check again - if it didn't work, we quit
if [[ ! -d "$matlab_path" ]]; then
    echo "MATLAB still not installed! Exiting."
    exit 1
fi

floating_license="$matlab_path/licenses/network.lic"
node_license=$(/usr/bin/find "$matlab_path/licenses" -name "license_*_${matlab_version}.lic")

# defaults before check
floating_license_installed=0
node_license_installed=0

# create archive directory
/bin/mkdir -p "$mamagement_folder"
# ensure the licenses directory is writable
/bin/chmod -R 775 "$matlab_path/licenses"


# check if the network license is installed
if [[ -f "$floating_license" ]]; then
    if grep -q "SERVER %LICENSE_SERVER%" "$floating_license" ; then
        echo "MATLAB floating license found:"
        echo "$floating_license"
        floating_license_installed=1
    fi
fi

# check if the node license is installed
if [[ -f "$node_license" ]]; then
    echo "MATLAB node license found:"
    echo "$node_license"
    node_license_installed=1
fi

if [[ $desired_license == "Floating" ]]; then
    if [[ $floating_license_installed == 1 ]]; then
        echo "$desired_license license already in place. Nothing to do!"
    else
        if [[ -f "$mamagement_folder/network.lic" ]]; then
            # move network lic into place
            echo "Moving MATLAB floating license into place"
            /bin/cp "$mamagement_folder/network.lic" "$floating_license"
        else
            # failsafe - write new license file
            echo "Writing MATLAB floating license"
            echo "$floating_license_content" > "$floating_license"
        fi
    fi
    # move node license away if present
    if [[ -f "$node_license" ]]; then
        echo "Moving MATLAB node license away"
        /bin/mv "$node_license" "$mamagement_folder/"
    fi
    # change app name to reflect floating license
    if [[ "$matlab_path" != "/Applications/MATLAB_${matlab_version}_Floating.app" ]]; then
        echo "Renaming to MATLAB_${matlab_version}_Floating.app"
        # is there an existing app of that name? better move it!
        if [[ -d "/Applications/MATLAB_${matlab_version}_Floating.app" ]]; then
            /bin/mv "/Applications/MATLAB_${matlab_version}_Floating.app" "/Applications/MATLAB_${matlab_version}_Floating_OLD_PLEASE_DELETE.app"
        fi
        /bin/mv "$matlab_path" "/Applications/MATLAB_${matlab_version}_Floating.app"
    fi

elif [[ $desired_license == "Node" ]]; then
    if [[ $node_license_installed == 1 ]]; then
        echo "$desired_license license already in place. Nothing to do!"
    else
        # check if node license archived and copy into place if so
        stored_node_license=$(/usr/bin/find "$mamagement_folder" -name  "license_*_$matlab_version.lic")
        if [[ -f "$stored_node_license" ]]; then
            # move node lic into place
            echo "Moving MATLAB node license into place"
            /bin/cp "$stored_node_license" "$matlab_path/licenses/"
        else
            echo "No existing MATLAB node license found. User must activate."
        fi
    fi
    # move network license away if present
    if [[ -f "$floating_license" ]]; then
        # move network lic into place
        echo "Moving MATLAB floating license away"
        /bin/mv "$floating_license" "$mamagement_folder/network.lic"
    fi
    # change app name to reflect node license
    if [[ "$matlab_path" != "/Applications/MATLAB_${matlab_version}_Node.app" ]]; then
        echo "Renaming to MATLAB_${matlab_version}_Node.app"
        # is there an existing app of that name? better move it!
        if [[ -d "/Applications/MATLAB_${matlab_version}_Node.app" ]]; then
            /bin/mv "/Applications/MATLAB_${matlab_version}_Node.app" "/Applications/MATLAB_${matlab_version}_Node_OLD_PLEASE_DELETE.app"
        fi
        /bin/mv "$matlab_path" "/Applications/MATLAB_${matlab_version}_Node.app"
    fi

else
    echo "No license type selected. Nothing to do!"
fi
