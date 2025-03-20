#!/bin/bash

#########################################################
# GLPI Agent config                                     #
# Created by Philippe Scholl                            #
# Version 2.1                                           #
# Copyright by Mac Product Center                       #
# Date: 08.10.2024                                      #
#########################################################

# Parameters
server_url="${4}"              # Server URL
debug="${5}"                   # Debug level
use_tag="${6}"                 # Tag function usage
tag_variable="${7}"            # Variable or Webserver of the tag variable
glpi_user="${8}"               # User for HTTP authentication
glpi_password="${9}"           # Password for HTTP authentication
ssl_fingerprint="${10}"        # SSL server certificate fingerprint

# Constants
CONFIG_FILE="/Applications/GLPI-Agent/etc/conf.d/local.cfg"

# Functions ###################################################################

# Write the default configuration to the GLPI local.cfg
function writeConfigDefaults() {
    {
        echo "server = ${server_url}"
        echo "debug = ${debug}"
        echo "no-httpd = 1"
        echo "no-p2p = 1"
        echo "logfile-maxsize = 4"
        echo "scan-homedirs = 0"
        echo "scan-profiles = 0"

        # Only add if values are non-empty
        [ -n "$glpi_user" ] && echo "user = ${glpi_user}"

        if [ -n "$glpi_password" ]; then
            if [[ "$glpi_password" == *'"'* ]]; then
                # If the password contains a double-quote, use single quotes
                echo "password = '$glpi_password'"
            else
                # Otherwise, use double quotes
                echo "password = \"$glpi_password\""
            fi
        fi

        [ -n "$ssl_fingerprint" ] && echo "ssl-fingerprint = ${ssl_fingerprint}"
    } > "$CONFIG_FILE"
}


# Write the old tag variable if it exists
function writeOLDTag() {
    if [ -n "$old_tag" ]; then
        echo "Setting old tag variable"
        echo "$old_tag" >> "$CONFIG_FILE"
    fi  
}

# Use Tag function
function writeTagServer() {
        tag=$(curl -s -m 10 "${tag_variable}?host=${HOSTNAME}")
        if echo "$tag" | grep -q -E "Customer:|archive:"; then
            echo "tag = ${tag}" >> "$CONFIG_FILE"
            echo "Tag successfully added"
        else 
            echo "HTML Return error: no tag variable available"
            writeOLDTag
        fi
}


function fetchOldTag() {
    if grep -q "^tag" "$CONFIG_FILE" 2>/dev/null; then
        old_tag=$(grep "^tag" "$CONFIG_FILE")
    else
        old_tag=""  # Set old_tag to empty if not found
    fi
}

# Main Script ###############################################################

# Check if server_url is empty
if [ -z "$server_url" ]; then
    echo "Error: Server URL is empty. Exiting."
    exit 0
fi

# Stop the GLPI daemon
sudo launchctl stop com.teclib.glpi-agent 

# Collect old tag variable from config file
fetchOldTag

# Write GLPI agent config
echo "Setting GLPI Default config"
writeConfigDefaults

# Check if Tag function is enabled
if [ "$use_tag" == "yes" ]; then
    # Check if tag_variable starts with "https://"
    if [[ "$tag_variable" == https://* ]]; then
        writeTagServer  # Call the function to handle server tag
    else
        # Check if tag_variable is not empty
        if [[ -n "$tag_variable" ]]; then
            echo "tag = ${tag_variable}" >> "$CONFIG_FILE"
        fi
    fi
fi

chmod 640 "$CONFIG_FILE"

# Start the GLPI daemon
sudo launchctl start com.teclib.glpi-agent

# Run an inventory
sudo /Applications/GLPI-Agent/bin/glpi-agent

exit