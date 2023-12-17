#!/bin/bash

#1
echo "Hello $USER"

#2
export COURSE_ID=DevOpsBootcampElevation

#3
if [ -e ~/.token ]; then
    permissions=$(stat -c "%a" ~/.token)
    if [ "$permissions" != "600" ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi

#4
umask 0006

#5
export PATH=$PATH:/home/$USER/usercommands

#6
echo "The current date is: $(date -u '+%Y-%m-%dT%H:%M:%S%:z')"

#7
alias ltxt="ls *.txt"

#8
if [ -d ~/tmp ]; then
    rm -rf ~/tmp/*
else
    mkdir ~/tmp
fi

#9
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    pid=$(lsof -Pi :8080 -sTCP:LISTEN -t)
    kill -9 "$pid"
fi
