#!/bin/bash

#######################################################################
#
# Uninstall Cytoscape
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

echo "Removing Cytoscape..."
#!/bin/bash

# Script to remove Cytoscape and related configuration files

# Define paths
APP_PATH="/Applications/Cytoscape_v3.10.3/Cytoscape.app"
FOLDER_PATH="/Applications/Cytoscape_v3.10.3"
CONFIG_PATH="/Users"

# Remove Cytoscape.app
if [ -e "$APP_PATH" ]; then
    echo "Removing $APP_PATH..."
    rm -rf "$APP_PATH"
else
    echo "$APP_PATH not found, skipping."
fi

# Remove parent folder
if [ -e "$FOLDER_PATH" ]; then
    echo "Removing $FOLDER_PATH..."
    rm -rf "$FOLDER_PATH"
else
    echo "$FOLDER_PATH not found, skipping."
fi

# Remove user configuration folders
echo "Searching for and removing configuration folders in $CONFIG_PATH..."
for USER_HOME in /Users/*; do
    USER_CONFIG_PATH="$USER_HOME/CytoscapeConfiguration"
    if [ -e "$USER_CONFIG_PATH" ]; then
        echo "Removing $USER_CONFIG_PATH..."
        rm -rf "$USER_CONFIG_PATH"
    else
        echo "$USER_CONFIG_PATH not found, skipping."
    fi
done

echo "Removal process completed."
exit 0