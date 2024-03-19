#!/bin/zsh

# script to delete obsolete Adobe Apps
for app_dir in /Applications/Adobe*/; do
    app_name=$(basename "$app_dir")
    if ! echo "$app_name" | egrep -q "Acrobat|Creative|Lightroom|2023|2024|2025|Rush 2|XD|Dimension|Dreamweaver 2021"; then
        rm -rf "$app_dir"
        echo "Deleting $app_name"
        echo "Checking if $app_name is actually deleted..."
        if [[ -d "${app_dir}" ]]; then
            echo "$app_name failed to delete"
        else
            echo "$app_name deleted successfully"
        fi
    fi
done

exit 0