#!/bin/bash

echo "Hello $USER"

export COURSE_ID="DevOpsBootcampElevation"

TOKEN="$HOME/.token"
if [ -e "$TOKEN" ]; then
    PERMISSIONS=$(stat -c "%a" "$TOKEN")
    if [ "$PERMISSIONS" -ne 600 ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi

umask 0006

export PATH=$PATH:"/home/$USER/usercommands"

current_date=$(date -u "+%Y-%m-%dT%H:%M:%S%z")
echo "Currentd date is: $current_date"
