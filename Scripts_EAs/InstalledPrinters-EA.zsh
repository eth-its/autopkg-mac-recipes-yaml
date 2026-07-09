#!/bin/zsh

installedprinters=$(lpstat -v|sed -e 's/device for //g')

if [[ -z $installedprinters ]] ; then installedprinters="None" ; fi

echo "<result>$installedprinters</result>"

exit 0