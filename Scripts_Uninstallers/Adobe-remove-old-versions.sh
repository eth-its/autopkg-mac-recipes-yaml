#!/bin/bash


#quit applications


sudo osascript -e 'quit app "Adobe InDesign 2020"'
sudo osascript -e 'quit app "Adobe After Effects 2020"'
sudo osascript -e 'quit app "Adobe Premiere Pro 2020"'
sudo osascript -e 'quit app "Adobe Illustrator 2020"'
sudo osascript -e 'quit app "Adobe Photoshop 2020"'


sudo osascript -e 'quit app "Adobe InDesign 2021"'
sudo osascript -e 'quit app "Adobe After Effects 2021"'
sudo osascript -e 'quit app "Adobe Premiere Pro 2021"'
sudo osascript -e 'quit app "Adobe Illustrator 2021"'
sudo osascript -e 'quit app "Adobe Photoshop 2021"'

sudo osascript -e 'quit app "Adobe InDesign 2022"'
sudo osascript -e 'quit app "Adobe After Effects 2022"'
sudo osascript -e 'quit app "Adobe Premiere Pro 2022"'
sudo osascript -e 'quit app "Adobe Illustrator 2022"'
sudo osascript -e 'quit app "Adobe Photoshop 2022"'

sudo osascript -e 'quit app "Adobe InDesign 2023"'
sudo osascript -e 'quit app "Adobe After Effects 2023"'
sudo osascript -e 'quit app "Adobe Premiere Pro 2023"'
sudo osascript -e 'quit app "Adobe Illustrator 2023"'
sudo osascript -e 'quit app "Adobe Photoshop 2023"'


#remove CC2020

rm -r "/Applications/Adobe InDesign 2020"
rm -r "/Applications/Adobe After Effects 2020"
rm -r "/Applications/Adobe Premiere Pro 2020"
rm -r "/Applications/Adobe Illustrator 2020"
rm -r "/Applications/Adobe Photoshop 2020"

#remove CC2021
rm -r "/Applications/Adobe InDesign 2021"
rm -r "/Applications/Adobe After Effects 2021"
rm -r "/Applications/Adobe Premiere Pro 2021"
rm -r "/Applications/Adobe Illustrator 2021"
rm -r "/Applications/Adobe Photoshop 2021"

#remove CC2022
rm -r "/Applications/Adobe InDesign 2022"
rm -r "/Applications/Adobe After Effects 2022"
rm -r "/Applications/Adobe Premiere Pro 2022"
rm -r "/Applications/Adobe Illustrator 2022"
rm -r "/Applications/Adobe Photoshop 2022"


#remove CC2023
rm -r "/Applications/Adobe InDesign 2023"
rm -r "/Applications/Adobe After Effects 2023"
rm -r "/Applications/Adobe Premiere Pro 2023"
rm -r "/Applications/Adobe Illustrator 2023"
rm -r "/Applications/Adobe Photoshop 2023"

echo "$Adobe old versions removal complete!"