#!/bin/zsh 
# shellcheck shell=bash

: <<DOC 
Lists obsolete Adobe Apps. Exclusions can be edited for e.g. Creative Cloud or Acrobat (or the version
of the titles we want to keep).

DOC
echo "<result>$(find /Applications/Adobe* -print -maxdepth 0 | egrep -v  "Acrobat|Creative|Lightroom|2023|2024|2025|Rush 2")</result>"

exit 0