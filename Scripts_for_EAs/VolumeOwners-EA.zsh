#!/bin/zsh
# shellcheck shell=bash

## List Volume Owners

enabled_users=()

while IFS= read line ; do
    enabled_users+="$(echo $line | cut -d, -f1)"
done <<< "$(/usr/bin/fdesetup list)"

[[ -z $enabled_users ]] && enabled_users=("None")

result="<result>"
for user in "${enabled_users[@]}"; do
    result+="${user},"
done
result=$(echo "$result" | sed 's|,$|</result>|')

echo "$result"
exit 0