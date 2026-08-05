#!/bin/zsh
lpadmin -p card-hp-IPP -D "card-hp IPP" -E -L "ETH cloud" -P "/Library/Printers/PPDs/Contents/Resources/HP Color MFP E87640-50-60.gz" \
-o HPOption_OutputBin=HP3BinMailbox -o HPOption_BookletMaker=True -o HPOption_HPFoldingOptions=MultiFold \
-o HPOption_HPStaplerOptions=HP2StapleUnit -o HPOption_HPPunchingOptions=HP24HolesUnit -o HPOption_Tray4=HP520SheetInputTray -o HPOption_Tray5=HP520SheetInputTray \
-o HPOption_Tray6=HP3000SheetInputTray -o HPColorAsGray=BlackInkOnly -o Duplex=DuplexNoTumble -o PageSize=A4 -o MediaType=Plain -o PageRegion=A4 \
-o ImageableArea=A4 -o PaperDimension=A4 -o HPBookletPageSize=A4 -o auth-info-required=username,password -v "ipps://pia01.d.ethz.ch:9164/printers/card-hp/auth"

loggedInUserID=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/kCGSSessionUserIDKey :/ { print $3 }' )

if [ ! -z $loggedInUserID ]; then 

cat >/tmp/testjob.sh <<EOT  
#!/bin/zsh
echo '\n\n\n'>/private/tmp/printjob.txt
osascript -e 'tell application "TextEdit" to print POSIX file "/private/tmp/printjob.txt" with properties {target printer:"card-hp-IPP"} without print dialog'
sleep 2
rm /private/tmp/printjob.txt
EOT
launchctl asuser $loggedInUserID /bin/zsh /tmp/testjob.sh
fi