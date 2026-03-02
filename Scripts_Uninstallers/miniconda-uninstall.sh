#!/bin/bash

# keep the system alive while it's running
caffeinate -d -i -m -u &
caffeinatepid=$!
conda deactivate || true 
/opt/miniconda3/_conda constructor uninstall --prefix /opt/miniconda3

# stop caffeinating
kill "$caffeinatepid"