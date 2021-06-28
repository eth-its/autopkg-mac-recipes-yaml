#!/bin/bash
## ETH_Templates_MSOffice preinstall script
## Supports Office 2016, 2019 and 365

template_dir="/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized"

# Remove existing versions to ensure only the new ones are presented
if [[ -d "$template_dir" ]]; then
    rm -rf "${template_dir:?}"/* ||:
fi