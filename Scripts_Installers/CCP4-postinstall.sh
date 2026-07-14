#!/bin/bash
## postinstall script to unpack & prepare CCP4

tarball=$(find /Library/Management/CCP4/ -type f -name 'ccp4*-shelx-arpwarp-macosarm.tar.gz'|sort|tail -n1)

if [[ -z $tarball ]] ; then echo "no tarball found to install ; aborting" ; exit 1 ; fi

cd /Applications
tar -zxf "${tarball}"
installedinto=$(find . -type d -name 'ccp*' -mindepth 1 -maxdepth 1 -newer ${tarball}|sort|tail -n1)
echo "CCP4 uncompressed to ${installedinto} ; installing .."
if [[ -f ${installedinto}/BINARY.setup ]] ; then 
	${installedinto}/BINARY.setup --run-from-script
	#clean up payload pkg and contents
	rm -f $tarball
	pkgutil --forget ch.ethz.id.pkg.ccp4 /
else
	echo "installation BINARY.setup not found, aborting" 
	exit 1
fi