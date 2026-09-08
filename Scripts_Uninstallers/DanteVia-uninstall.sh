#!/usr/bin/env bash

pkill "Dante Via"

DANTE_VIA_UNINSTALL_SCRIPT="/Library/Application Support/Audinate/DanteVia/Resources/DanteViaUninstall.command"

if [[ ! -f "$DANTE_VIA_UNINSTALL_SCRIPT" ]]; then
    echo -e "Dante Via uninstallation failed!\n\nUninstaller script not found at\n'$DANTE_VIA_UNINSTALL_SCRIPT'"
    exit 1
fi

exec "$DANTE_VIA_UNINSTALL_SCRIPT"
pkgutil --forget com.audinate.pkg.DanteVia /