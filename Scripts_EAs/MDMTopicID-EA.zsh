#!/bin/zsh
# shellcheck shell=bash

## Displasy the MDM APNS Topic ID. This is used to look for outliers which may indicate expired MDM certificates or other issues

apns_topic=$(/usr/sbin/system_profiler SPConfigurationProfileDataType | awk '/Topic/{ print $NF }' | sed 's/[";]//g')

  if [[ "$apns_topic" = "" ]]; then
      result="None"
  else
      result="$apns_topic"
  fi

  echo "<result>$result</result>"
