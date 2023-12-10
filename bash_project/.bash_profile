#!/bin/bash


#   ____  ____  _      _____    _     ____  ____  _  __   ____  _____    _     ___  _   ____  ____  ____  _____
#  /  _ \/  _ \/ \  /|/__ __\  / \   /  _ \/  _ \/ |/ /  /  _ \/__ __\  / \__/|\  \//  /   _\/  _ \/  _ \/  __/
#  | | \|| / \|| |\ ||  / \    | |   | / \|| / \||   /   | / \|  / \    | |\/|| \  /   |  /  | / \|| | \||  \
#  | |_/|| \_/|| | \||  | |    | |_/\| \_/|| \_/||   \   | |-||  | |    | |  || / /    |  \__| \_/|| |_/||  /_
#  \____/\____/\_/  \|  \_/    \____/\____/\____/\_|\_\  \_/ \|  \_/    \_/  \|/_/     \____/\____/\____/\____\


#A
echo "Hello" $USER
#B
export COURSE_ID="DevOpsBootcampElevation"
#IF
if [ -e ~/.token ]; then
    permissions=$(stat -c "%a" ~/.token)
    if [ "$permissions" != "600" ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi
#umask
umask 0006

#adding path to existing path the user home directory 
export PATH=$PATH:/home/$USER/usercommands

#echo date specific form
echo "The current date is: $(date -u +'%Y-%m-%dT%H:%M:%S%:z')"

#new alias to funtion 
alias ltxt='ls *.txt'

#create temp clean directory

if [ -d ~/tmp ]; then
    rm -rf ~/tmp/*
else
    mkdir ~/tmp
fi


#kill service port 8080
# Check if the port is already in use
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    # Get the PID of the process using port 8080
    pid=$(lsof -Pi :8080 -sTCP:LISTEN -t)
    # Kill the process
    kill -9 "$pid"
fi
