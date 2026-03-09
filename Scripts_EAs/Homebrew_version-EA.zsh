#!/bin/zsh

intel_brew="/usr/local/bin/brew"
arm_brew="/opt/homebrew/bin/brew"

homebrew_owner=$(stat -f%Su $intel_brew 2>/dev/null || stat -f%Su $arm_brew 2>/dev/null )
current_user=$(/usr/bin/stat -f %Su /dev/console)
most_logged_user=$(last|grep console|awk {'print $1'}|sort|uniq -c|sort|tail -n1|awk {'print $2'})

if [[ $homebrew_owner == $most_logged_user && $homebrew_owner == $current_user ]] ; then 
    localuser=$homebrew_owner
elif [[ $current_user == $homebrew_owner ]] ; then
    localuser=$current_user
else
    localuser=$most_logged_user
fi

if [ -f "$arm_brew" ]; then
    result=$(sudo -u $localuser zsh -c "$arm_brew --version | tr -d 'Homebrew '")
elif [ -f "$intel_brew" ]; then
    result=$(sudo -u $localuser zsh -c "$intel_brew --version | tr -d 'Homebrew '")
else
    result="None"
fi

echo "<result>$result</result>"
