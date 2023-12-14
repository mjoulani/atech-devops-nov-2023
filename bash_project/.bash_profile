#!/bin/bash

echo "Hello $(whoami)"



export COURSE_ID=DevOpsBootcampElevation



if [ -e ~/.token ]; then
    TOKEN_PERMISSIONS=$(stat -c "%a" ~/.token)
    if [ "$TOKEN_PERMISSIONS" != "600" ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi



umask 0006


export PATH=$PATH:/home/$USER/usercommands




echo "The current date is: $(date -u +"%Y-%m-%dT%H:%M:%S%:z")"


alias ltxt='ls *.txt'




if [ -d ~/tmp ]; then
    rm -rf ~/tmp/*
else
    mkdir ~/tmp
fi


lsof -i :8080 -t | xargs kill -9 2>/dev/null
