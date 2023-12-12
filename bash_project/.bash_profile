#!/bin/bash

username=$(whoami)
echo "Hello $username"

export COURSE_ID=DevOpsBootcampElevation

if [ -f ~/.token ]
then
    token_permissions=$(stat -c %a ~/.token)
    if [[ token_permissions != 600 ]]
    then
	    echo "Warning: .token file has too open permissions"
    else;
    fi
fi

umask 007

PATH+=":/home/$username/usercommands"

formated_date=$(date --utc +'%Y-%m-%dT%H:%M:%S+00:00')
echo "The current date is: $formated_date"

alias ltxt="ls -l | grep '.txt$'"

if ! [ -d $HOME/tmp ]
then 
        mkdir $HOME/tmp
else
        rm -rf $HOME/tmp/*
fi

process_8080=$(lsof -t -i:8080)

if ! [ -z "$process_8080" ]
then
	kill -9 $process_8080
fi
