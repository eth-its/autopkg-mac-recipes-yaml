#!/bin/bash

# Pfad zu Amazon Corretto
CORRETTO_PATH="/Library/Java/JavaVirtualMachines/amazon-corretto-11.jdk"

# Überprüfen, ob Amazon Corretto installiert ist
if [ -d "$CORRETTO_PATH" ]; then
    echo "Amazon Corretto is installed. Removing it now..."
    
    # In das Verzeichnis wechseln und Amazon Corretto löschen
    cd /Library/Java/JavaVirtualMachines/ || {
        echo "Failed to navigate to /Library/Java/JavaVirtualMachines/. Exiting."
        exit 1
    }
    
    sudo rm -rf amazon-corretto-11.jdk

    if [ ! -d "$CORRETTO_PATH" ]; then
        echo "Amazon Corretto has been successfully removed."
    else
        echo "Failed to remove Amazon Corretto. Please check permissions or try manually."
    fi
else
    echo "Amazon Corretto is not installed."
fi
