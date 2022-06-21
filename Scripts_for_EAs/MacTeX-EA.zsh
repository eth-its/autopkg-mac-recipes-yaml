#!/bin/zsh
# shellcheck shell=bash

# MacTeX Versioner
# MacTeX doesn't supply a version, but is released once a year. 
# This EA grabs the year from /Library/TeX/Distributions/.DefaultTeX/Contents/Resources/English.lproj

tex_version=$( cat /Library/TeX/Distributions/.DefaultTeX/Contents/Resources/English.lproj/Description.rtf | grep "TeX Live" | awk '{print $(NF-1)}' )

[[ $tex_version ]] || tex_version="None"

echo "<result>$tex_version</result>"

exit 0