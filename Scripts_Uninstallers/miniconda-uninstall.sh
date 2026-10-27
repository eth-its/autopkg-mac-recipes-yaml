#!/bin/bash

# keep the system alive while it's running
caffeinate -d -i -m -u &
caffeinatepid=$!
conda deactivate || true 
/opt/miniconda3/_conda constructor uninstall --prefix /opt/miniconda3

pkgutil --forget io.continuum.pkg.prepare_installation ||:
pkgutil --forget io.continuum.pkg.run_conda_init ||:
pkgutil --forget io.continuum.pkg.run_installation ||:
pkgutil --forget io.continuum.pkg.shortcuts ||:

if [ -f /var/db/receipts/com.anaconda.pkg.prepare_installation.plist ] ; then 
pkgutil --forget com.anaconda.pkg.prepare_installation ||:
pkgutil --forget com.anaconda.pkg.run_conda_init ||:
pkgutil --forget com.anaconda.pkg.run_installation ||:
pkgutil --forget com.anaconda.pkg.shortcuts ||:
fi


# stop caffeinating
kill "$caffeinatepid"