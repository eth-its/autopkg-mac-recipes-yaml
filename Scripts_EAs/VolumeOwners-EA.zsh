#!/bin/zsh
# shellcheck shell=bash

## List Volume Owners

enabled_users=()

while IFS= read line ; do
    enabled_users+="$(echo $line | cut -d, -f1)"
done <<< "$(/usr/bin/fdesetup list)"

[[ -z $enabled_users ]] && enabled_users=("None")

# if not Apple Silicon we don't care
[[ "$(/usr/bin/arch)" != "arm64"* ]] && enabled_users=("Intel Mac - Volume Owner not required")

result="<result>"
for user in "${enabled_users[@]}"; do
    result+="${user},"
done
result=$(echo "$result" | sed 's|,$|</result>|')

echo "$result"
exit 0