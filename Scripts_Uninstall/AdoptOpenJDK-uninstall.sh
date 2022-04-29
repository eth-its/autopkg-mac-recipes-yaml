#!/bin/bash

filter="$4"

if [[ ! $filter ]]; then
    echo "No version supplied"
    exit 1
fi

if [[ $filter -lt 9 ]]; then 
    filter_name="1.$filter"
else
    filter_name="$filter"
fi

has_jvm=1
while [[ $has_jvm == 1 ]]; do
    echo "Checking for JVM..."
    # get the JVM version using java_home
    latest_jvm=$(/usr/libexec/java_home -X -v "$filter_name" | grep -A2 -m3 AdoptOpenJDK | tail -n 1 | sed 's|<[^>]*>||g' | sed 's|^[[:space:]]*||' | grep "$filter_name." )
    if [[ $latest_jvm ]]; then
        jvm_path=$( /usr/libexec/java_home -X -v "$filter_name" | grep -B9 -m10 AdoptOpenJDK | grep -A1 JVMHomePath | tail -n 1 | sed 's|<[^>]*>||g' | sed 's|^[[:space:]]*||' | sed 's|\/Contents\/Home||' )
        if [[ -d "$jvm_path" ]]; then
            echo "Deleting '$jvm_path'"
            rm -Rf "$jvm_path"
        else
            echo "ERROR: $jvm_path is not a directory."
        fi
    else
        echo "No JVM with version $filter is installed"
        has_jvm=0
    fi
done
