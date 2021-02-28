#!/bin/bash

filter="$4"

if [[ $filter -lt 9 ]]; then 
    filter_check="1.$filter"
else
    filter_check="$filter"
fi

has_jvm=1

while [[ $has_jvm == 1 ]]; do
    echo "Checking for JVM..."
    jvm_path=$( /usr/libexec/java_home -X -v "$filter_check" | grep -B9 -m10 AdoptOpenJDK | grep -A1 JVMHomePath | tail -n 1 | sed 's|<[^>]*>||g' | sed 's|^[[:space:]]*||' | sed 's|\/Contents\/Home||' | grep "$filter_check." )
    if [[ -d "$jvm_path" ]]; then
        echo "Deleting '$jvm_path'"
        rm -Rf "$jvm_path"
    else
        echo "No JVM with version $filter is installed"
        has_jvm=0
    fi
done
