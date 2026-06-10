#!/bin/zsh

if [ ${#1} -lt 2 ] ; then echo 'requires name as parameter' ; exit 0 ; fi 

baselocation=$(basename ${0:A:h})

if [ $baselocation != "_Deprecated_Recipes" ] ; then echo "_Deprecated_Recipes folder not found - please run this from the _Deprecated_Recipes folder of the repo" ; exit 0 ; fi

sourcelist=($(find ../ -name "$1*"|grep -v _Deprecated_Recipes))
for entry in ${sourcelist[@]}; do
echo $entry
done
if [[ ${#sourcelist} == 0 ]]; then echo "nothing found - exiting" ; exit 0 ; fi

echo "Do you want to deprecate the above ?"  
echo "Y/N and enter please?"
read userchoice

if [[ ${userchoice} != Y ]] ; then echo "Didn't choose Y, aborting" ; exit 0 ; fi

for entry in ${sourcelist[@]}; do
destination=$(echo $entry|sed -e 's/^\.\.\//.\//')
if [[ ! -d $(dirname $destination) ]] ; then echo "missing destination directory $(dirname $destination) , creating" ; mkdir $(dirname $destination) ; fi
echo Moving $entry to $destination
mv $entry $destination
done

