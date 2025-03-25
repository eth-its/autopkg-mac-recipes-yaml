#!/bin/zsh

#########################################################
# macOS Updates										    #
# created by Philippe Scholl                            #
# version 2.1										    #
# copyright by Mac Product Center                       #
# Date: 24.03.2025                                      #
#########################################################


recommended_updates=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate RecommendedUpdates)

if echo "$recommended_updates" | grep -q "Identifier"; then
  echo "<result>true</result>"
else
  echo "<result>false</result>"
fi
exit 0