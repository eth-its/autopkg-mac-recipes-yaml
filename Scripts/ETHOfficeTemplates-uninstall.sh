#!/bin/bash
## ETH_Templates_MSOffice uninstallation
## Supports Office 2016, 2019 and 365

template_dir="/Library/Application Support/Microsoft/Office365/User Content.localized/Templates.localized"

# remove templates
if [[ -d "$template_dir" ]]; then
    rm -rf "${template_dir:?}"/* ||:
fi

# remove the defaults version key
/usr/bin/defaults delete /Library/Preferences/ch.ethz.id.ETHTemplatesMSOffice 2>/dev/null

# forget the package receipt
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"

receipts=$($pkgutilcmd --pkgs=ch.ethz.id.pkg.ETHTemplatesMSOffice*)
while read -r receipt; do
    $pkgutilcmd --pkgs="${receipt}" && $pkgutilcmd --forget "${receipt}"
done <<< "${receipts}"        
