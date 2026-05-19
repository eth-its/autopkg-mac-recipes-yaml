#!/bin/bash
## postinstall script to restrict Adobe Acrobat (not reader any more) settings

# remove any existing version of the tool
adobe_pro_prefs='
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>DC</key>
	<dict>
		<key>FeatureLockdown</key>
		<dict>
		    <key>bAcroSuppressUpsell</key>
            <true/>
			<key>bUpdater</key>
			<false/>
			<key>bEnableADMAnalytics</key>
			<false/>
			<key>cGeneral</key>
			<dict>
				<key>bToggleCustomOpenSaveExperience</key>
				<false/>
			</dict>
			<key>cServices</key>
			<dict>
				<key>bToggleAdobeDocumentServices</key>
				<false/>
				<key>bToggleAdobeSign</key>
				<false/>
				<key>bToggleDocumentCloud</key>
				<false/>
				<key>bToggleDocumentConversionServices</key>
				<false/>
				<key>bToggleFillSign</key>
				<false/>
				<key>bToggleMobileLink</key>
				<false/>
				<key>bToggleSendAndTrack</key>
				<false/>
				<key>bToggleWebConnectors</key>
				<false/>
				<key>bUpdater</key>
				<false/>
				<key>bUsageMeasurement</key>
				<false/>
			</dict>
			<key>cWebmailProfiles</key>
			<dict>
				<key>bDisableWebmail</key>
				<true/>
			</dict>
		</dict>
	</dict>
</dict>
</plist>
'

echo "$adobe_pro_prefs" > /Library/Preferences/com.adobe.Acrobat.Pro.plist 
