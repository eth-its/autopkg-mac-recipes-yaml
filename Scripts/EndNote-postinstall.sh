#!/bin/bash

endnote_version="EndNote %MAJOR_VERSION%"
exit_code=0

# copy plugins
ms_office_16_bundle="/Applications/$endnote_version/Cite While You Write/EndNote CWYW Word 16.bundle"
ms_office_2016_bundle="/Applications/$endnote_version/Cite While You Write/EndNote CWYW Word 2016.bundle"
pages_bundle="/Applications/$endnote_version/Cite While You Write/PagesEndNote.bundle"

ms_office_bundle_destination="/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word"
pages_bundle_destination="/Library/Application Support/ResearchSoft/EndNote/Plugins"

if [[ -d "$ms_office_16_bundle" ]]; then
    echo "Copying $ms_office_16_bundle to $ms_office_bundle_destination"
    mkdir -p "$ms_office_bundle_destination"
    cp -r "$ms_office_16_bundle" "$ms_office_bundle_destination/EndNote CWYW Word 16.bundle"
    if [[ -d "$ms_office_bundle_destination/EndNote CWYW Word 16.bundle" ]]; then
        echo "EndNote CWYW Word 16.bundle copied successfully"
    else
        echo "ERROR: EndNote CWYW Word 16.bundle failed to copy"
        exit_code=1
    fi
elif [[ -d "$ms_office_2016_bundle" ]]; then
    mkdir -p "$ms_office_bundle_destination"
    cp -r "$ms_office_2016_bundle" "$ms_office_bundle_destination/EndNote CWYW Word 2016.bundle"
    if [[ -d "$ms_office_bundle_destination/EndNote CWYW Word 2016.bundle" ]]; then
        echo "EndNote CWYW Word 2016.bundle copied successfully"
    else
        echo "ERROR: EndNote CWYW Word 2016.bundle failed to copy"
        exit_code=1
    fi
else
    echo "$ms_office_16_bundle and $ms_office_2016_bundle not found. Nothing to copy."
fi

if [[ -d "$pages_bundle" ]]; then
    mkdir -p "$pages_bundle_destination"
    cp -r "$pages_bundle" "$pages_bundle_destination/PagesEndNote.bundle"
    if [[ -d "$pages_bundle_destination/PagesEndNote.bundle" ]]; then
        echo "PagesEndNote.bundle copied successfully"
    else
        echo "ERROR: PagesEndNote.bundle failed to copy"
        exit_code=1
    fi
else
    echo "$pages_bundle not found. Nothing to copy."
fi

exit $exit_code
