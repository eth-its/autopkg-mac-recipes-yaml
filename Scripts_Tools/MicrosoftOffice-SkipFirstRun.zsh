#!/bin/zsh
defaults write /Library/Preferences/com.microsoft.office.plist OfficeAutoSignIn -bool FALSE
defaults write /Library/Preferences/com.microsoft.office.plist ShowWhatsNewOnLaunch -bool FALSE
defaults write /Library/Preferences/com.microsoft.office.plist HasUserSeenEnterpriseFREDialog -bool TRUE
defaults write /Library/Preferences/com.microsoft.Word.plist kSubUIAppCompletedFirstRunSetup1507 -bool true
defaults write /Library/Preferences/com.microsoft.Excel.plist kSubUIAppCompletedFirstRunSetup1507 -bool true
defaults write /Library/Preferences/com.microsoft.Powerpoint.plist kSubUIAppCompletedFirstRunSetup1507 -bool true
defaults write /Library/Preferences/com.microsoft.Outlook.plist kSubUIAppCompletedFirstRunSetup1507 -bool true
exit 0
