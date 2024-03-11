#!/bin/bash

# script to delete obsolete Adobe Apps
for app_dir in /Applications/Adobe*/; do
    app_name=$(basename "$app_dir")
    if ! echo "$app_name" | egrep -q "Acrobat|Creative|2023|2024|2025"; then
        rm -rf "$app_dir"
        echo "Lösche $app_name"
    fi
done

exit 0