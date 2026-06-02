#!/bin/zsh
#grab the version number of the HP UniPS Drivers that was just installed, and write it into a receipt plist 
plist_file=/private/var/db/receipts/com.hp.pkg.swls.printer-essentials-UniPS.version.plist
installed_version=$(tail -n 500 /var/log/install.log|grep -e HP-Drivers-UniPS|sed -e 's/.*HP-Drivers-UniPS-\([0-9|\.].*\).pkg.*/\1/'|grep -v \#|uniq|head -1)
if [[ $(echo $installed_version|wc -c) -lt 7 ]] ; then installed_version="Unknown" ; fi
installed_timestamp=$(date -u +"%Y-%m-%dT %H:%M:%S %z")
pl_write() { 
defaults write ${plist_file} $1 $2
}
pl_write PackageVersion "${installed_version}"
pl_write PackageFileName "hp-printer-essentials-UniPS.version.pkg"
pl_write PackageIdentifier "com.hp.pkg.swls.printer-essentials-UniPS.version"
pl_write InstallProcessName "installer"
pl_write InstallPrefixPath "/"
pl_write InstallDate "${installed_timestamp}"
chmod 644 ${plist_file}
xattr -c ${plist_file}