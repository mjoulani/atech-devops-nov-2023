#!/bin/bash

echo "Hello $(id -un)"



export COURSE_ID="DevOpsBootcampElevation"


#if [ -f ~/.token ]; then
##	permissions=$(stat -c "%a" ~/.token)
#	if [[ "$permissions" != "600" ]]; then
#	  echo "Warning: The permissions for .token file are different from 600"
#	fi
#fi

if [ -e ~/.token ]; then
    permissions=$(stat -c "%a" ~/.token)
    if [ "$permissions" != "600" ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi

umask 0006


export PATH=$PATH:/home/$USER/usercommands


date -u +%FT%TZ


alias ltxt='ls *.txt'



if [ -d ~/tmp ]; then
    rm -rf ~/tmp/*
else
    mkdir ~/tmp
fi

sudo lsof -i :8080

sudo kill PID



