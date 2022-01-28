#!/bin/bash
## ETH_Templates_MSOffice uninstallation
## Supports Office 2016, 2019 and 365

template_dir="/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized"

# remove templates
if [[ -d "$template_dir" ]]; then
    rm -rf "${template_dir:?}"/* ||:
fi

# remove the defaults version key
/usr/bin/defaults delete /Library/Preferences/ch.ethz.id.ETHTemplatesMSOffice 2>/dev/null ||:

# forget the package receipt
pkgutilcmd="/usr/sbin/pkgutil"

receipts=$($pkgutilcmd --pkgs=ch.ethz.id.pkg.ETHTemplatesMSOffice* 2>/dev/null)
while read -r receipt; do
    if $pkgutilcmd --pkgs="${receipt}"; then
        echo "Forgetting package ${receipt}"
        $pkgutilcmd --forget "${receipt}"
    fi
done <<< "${receipts}"        
