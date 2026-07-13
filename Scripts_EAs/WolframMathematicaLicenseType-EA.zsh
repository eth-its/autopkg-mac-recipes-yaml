#!/bin/zsh
# Check for Wolfram License presence&type
if [[ -f  /Library/Wolfram/Licensing/mathpass ]] ; then 
  if [[ $(grep -c 'lic-mathematica' /Library/Wolfram/Licensing/mathpass) == 0 ]] ; then lictype="Node" 
  else lictype="Floating"
  fi
else
  lictype="None"
fi

echo "<result>$lictype</result>"
exit 0