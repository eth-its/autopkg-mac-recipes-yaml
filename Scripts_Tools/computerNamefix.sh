#!/bin/zsh
#########################################################
# Auto rename HostName and LocalHostName to ComputerName
# created by Philippe Scholl edited by Katiuscia Zehnder
# version 1.0.4
# 2025-11-10
# copyright by ethOS Mac Product Center
#########################################################

computerName="$2"

if [[ -z "$computerName" ]]; then
  echo "Error: No computer name provided."
  exit 1
fi

if jamf setComputerName -name "$computerName"; then
  echo "Successfully changed Computer Name to $computerName"
  # Inventar in Jamf Pro aktualisieren, recon done within Policy
  #jamf recon >/dev/null 2>&1 || echo "Note: recon failed (non-fatal)."
else
  echo "Failed to change Computer Name!"
  exit 1
fi