#!/bin/bash
echo "Hello $USER!"

#Define an environment
export COURSE_ID="DevOpsBootcampElevation"

# Checking for .token file
if [ -f ~/.token ]; then
    if [[ $(stat -c '%a' ~/.token) != "600" ]]; then
        echo 'Warning: .token file has too open permissions'
    fi
fi

# SChange umask to set default permissions of new files
umask 0077

# Add /home/<username>/usercommands to the end of the PATH
export PATH=$PATH:/home/$USER/usercommands

# Print the current date
date=$(date -u +"%Y-%m-%dT%H:%M:%S%:z")
echo "Current date: $date"

# Define a command alias for printing .txt files
alias ltxt='ls *.txt'

# Managing temporary directory (creat or clean)
if [ ! -d ~/tmp ]; then
    mkdir ~/tmp
else
    rm -rf ~/tmp/*
fi

# Kill the process bound to port 8080 (if it exists)
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null; then
    echo "Terminating the process running on port 8080..."
    kill -9 $(lsof -t -i:8080)
else
    echo "No process is currently running on port 8080."
fi