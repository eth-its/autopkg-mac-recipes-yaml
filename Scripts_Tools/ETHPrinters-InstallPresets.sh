#!/bin/zsh
cat >/tmp/com.apple.print.custompresets-template.plist <<'EOT'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>B/W Double-sided - ETH Default</key>
	<dict>
		<key>com.apple.print.preset.behavior</key>
		<integer>0</integer>
		<key>com.apple.print.preset.id</key>
		<string>B/W Double-sided - ETH Default</string>
		<key>com.apple.print.preset.settings</key>
		<dict>
			<key>AP_ColorMatchingMode</key>
			<string>AP_ApplicationColorMatching</string>
			<key>DuplexBindingEdge</key>
			<integer>2</integer>
			<key>HPColorAsGray</key>
			<string>BlackInkOnly</string>
			<key>HPJobName</key>
			<string>DocName</string>
			<key>HPSheetsPerSet</key>
			<string>False</string>
			<key>HPUserAccessCode</key>
			<string>None</string>
			<key>HPwmTextMessage</key>
			<string>Draft</string>
			<key>OutputBin</key>
			<string>None</string>
			<key>com.apple.print.PageToPaperMappingAllowScalingUp</key>
			<true/>
			<key>com.apple.print.PrintSettings.PMColorSpaceModel</key>
			<integer>2</integer>
			<key>com.apple.print.PrintSettings.PMDuplexing</key>
			<integer>2</integer>
			<key>com.apple.print.pageRange</key>
			<string>All 4 Pages</string>
		</dict>
	</dict>
	<key>B/W Single-sided</key>
	<dict>
		<key>com.apple.print.preset.behavior</key>
		<integer>0</integer>
		<key>com.apple.print.preset.id</key>
		<string>B/W Single-sided</string>
		<key>com.apple.print.preset.settings</key>
		<dict>
			<key>AP_ColorMatchingMode</key>
			<string>AP_ApplicationColorMatching</string>
			<key>Duplex</key>
			<string>None</string>
			<key>DuplexBindingEdge</key>
			<integer>2</integer>
			<key>HPColorAsGray</key>
			<string>BlackInkOnly</string>
			<key>HPJobName</key>
			<string>DocName</string>
			<key>HPSheetsPerSet</key>
			<string>False</string>
			<key>HPUserAccessCode</key>
			<string>None</string>
			<key>HPwmTextMessage</key>
			<string>Draft</string>
			<key>OutputBin</key>
			<string>None</string>
			<key>PMFinishingOptionSelection</key>
			<integer>2</integer>
			<key>com.apple.print.PageToPaperMappingAllowScalingUp</key>
			<true/>
			<key>com.apple.print.PrintSettings.PMColorSpaceModel</key>
			<integer>2</integer>
			<key>com.apple.print.PrintSettings.PMDuplexing</key>
			<integer>1</integer>
			<key>com.apple.print.pageRange</key>
			<string>All 4 Pages</string>
		</dict>
	</dict>
	<key>Colour Double-sided</key>
	<dict>
		<key>com.apple.print.preset.behavior</key>
		<integer>0</integer>
		<key>com.apple.print.preset.id</key>
		<string>Colour Double-sided</string>
		<key>com.apple.print.preset.settings</key>
		<dict>
			<key>AP_ColorMatchingMode</key>
			<string>AP_ApplicationColorMatching</string>
			<key>DuplexBindingEdge</key>
			<integer>2</integer>
			<key>HPColorAsGray</key>
			<string>None</string>
			<key>HPJobName</key>
			<string>DocName</string>
			<key>HPSheetsPerSet</key>
			<string>False</string>
			<key>HPUserAccessCode</key>
			<string>None</string>
			<key>HPwmTextMessage</key>
			<string>Draft</string>
			<key>OutputBin</key>
			<string>None</string>
			<key>com.apple.print.PageToPaperMappingAllowScalingUp</key>
			<true/>
			<key>com.apple.print.PrintSettings.PMColorSpaceModel</key>
			<integer>2</integer>
			<key>com.apple.print.PrintSettings.PMDuplexing</key>
			<integer>2</integer>
			<key>com.apple.print.pageRange</key>
			<string>All 4 Pages</string>
		</dict>
	</dict>
	<key>Colour Single-sided</key>
	<dict>
		<key>com.apple.print.preset.behavior</key>
		<integer>0</integer>
		<key>com.apple.print.preset.id</key>
		<string>Colour Single-sided</string>
		<key>com.apple.print.preset.settings</key>
		<dict>
			<key>AP_ColorMatchingMode</key>
			<string>AP_ApplicationColorMatching</string>
			<key>Duplex</key>
			<string>None</string>
			<key>DuplexBindingEdge</key>
			<integer>2</integer>
			<key>HPColorAsGray</key>
			<string>None</string>
			<key>HPJobName</key>
			<string>DocName</string>
			<key>HPSheetsPerSet</key>
			<string>False</string>
			<key>HPUserAccessCode</key>
			<string>None</string>
			<key>HPwmTextMessage</key>
			<string>Draft</string>
			<key>OutputBin</key>
			<string>None</string>
			<key>PMFinishingOptionSelection</key>
			<integer>2</integer>
			<key>com.apple.print.PageToPaperMappingAllowScalingUp</key>
			<true/>
			<key>com.apple.print.PrintSettings.PMColorSpaceModel</key>
			<integer>2</integer>
			<key>com.apple.print.PrintSettings.PMDuplexing</key>
			<integer>1</integer>
			<key>com.apple.print.pageRange</key>
			<string>All 4 Pages</string>
		</dict>
	</dict>
	<key>com.apple.print.customPresetsInfo</key>
	<array>
		<dict>
			<key>PresetBehavior</key>
			<integer>0</integer>
			<key>PresetName</key>
			<string>B/W Double-sided - ETH Default</string>
		</dict>
		<dict>
			<key>PresetBehavior</key>
			<integer>0</integer>
			<key>PresetName</key>
			<string>B/W Single-sided</string>
		</dict>
		<dict>
			<key>PresetBehavior</key>
			<integer>0</integer>
			<key>PresetName</key>
			<string>Colour Double-sided</string>
		</dict>
		<dict>
			<key>PresetBehavior</key>
			<integer>0</integer>
			<key>PresetName</key>
			<string>Colour Single-sided</string>
		</dict>
	</array>
	</dict>
</plist>
EOT
chmod 755 /tmp/com.apple.print.custompresets-template.plist
loggedinuser=$(who|grep console|awk {'print $1'})
if [[ ! -z $loggedinuser ]] ; then 
sudo -u $loggedinuser zsh -c "plutil -convert json -o - Library/Preferences/com.apple.print.custompresets.plist|jq -r 'keys[]'|grep -v 'com.apple.print.customPresetsInfo\|Default Settings'>/tmp/preexisting-custompresets.txt"
# apply the presets for the current user
sudo -u $loggedinuser zsh -c 'defaults import com.apple.print.custompresets /tmp/com.apple.print.custompresets-template.plist'
# if we found preexisting presets, we'll have to make sure they persist in the 'customPresetsInfo' list, so that they're presented to the user still. 
# to do that, we mcgyver a json list of dicts with the preset names, name that list 'customPresetsInfo', and inject the resulting plist again.
if [[ $(cat /tmp/preexisting-custompresets.txt|wc -l) -gt 0 ]] ; then 
echo $(printf '{"com.apple.print.customPresetsInfo":['; for line in "${(@f)"$(</tmp/preexisting-custompresets.txt)"}"; { echo "{ \"PresetBehavior\":0, \"PresetName\":\"$line\"}," } ; printf ']}') | plutil -convert xml1 - -o /tmp/custompresetlist.plist
sudo -u $loggedinuser zsh -c 'defaults import com.apple.print.custompresets /tmp/custompresetlist.plist'
fi
rm -f /tmp/custompresetlist.plist /tmp/preexisting-custompresets.txt /tmp/com.apple.print.custompresets-template.plist ||:
fi