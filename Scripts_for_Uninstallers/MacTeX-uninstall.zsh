#!/bin/zsh
# shellcheck shell=bash

#######################################################################
#
# Uninstall MacTeX
#
#######################################################################

# close any open GUI apps 
MacTeXApps=( "TeXLive" "TeXShop" "LaTeXiT" "BibDesk" "texmaker" )
for appName in "${MacTeXApps[@]}"; do
    if [[ $(pgrep -x "$appName") ]]; then
        echo "Closing $appName"
        osascript -e "quit app \"$appName\""
        sleep 1

        # double-check
        countUp=0
        while [[ $countUp -le 10 ]]; do
            if [[ -z $(pgrep -x "$appName") ]]; then
                echo "$appName closed."
                break
            else
                let countUp=$countUp+1
                sleep 1
            fi
        done
        if [[ $(pgrep -x "$appName") ]]; then
            echo "$appName failed to quit - killing."
            /usr/bin/pkill "$appName"
        fi
    fi
done

echo "remove TeX Gui applications (/Applications/TeX)"
rm -rf /Applications/TeX ||:

echo "remove TeX Live distributions (/usr/local/texlive)"
rm -rf /usr/local/texlive ||:


echo "remove TeX Distribution pane on the System Preferences.app"
rm -rf /Library/PreferencePanes/TeXDistPrefPane.prefPane ||:
echo "remove items in /Library/TeX"
rm -rf /Library/TeX/.scripts /Library/TeX/Distributions ||:
rm -f /Library/TeX/Documentation /Library/TeX/Local /Library/TeX/Root ||:

# Forget packages
echo "Forgetting packages"
pkgutilcmd="/usr/sbin/pkgutil"

receipts=$(pkgutil --pkgs=org.tug.mactex*)
while read -r receipt; do
    $pkgutilcmd --pkgs=${receipt} && $pkgutilcmd --forget ${receipt}
done <<< "${receipts}"
