#!/bin/bash 
set -e
if [ -f ~/.token  ]; then
    PR=$(stat -c '%a' ~/.token)
    if [ $PR -ne 600 ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi