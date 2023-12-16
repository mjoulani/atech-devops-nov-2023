#!/bin/bash

# Greet the user
echo "Hello $USER"

# Define an environment variable called COURSE_ID
export COURSE_ID=DevOpsBootcampElevation

# Check if the .token file exists before checking permissions
if [ -f ~/.token ]; then
    permissions=$(stat -c "%a" ~/.token)
    if [ "$permissions" != "600" ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi

# Change the umask of the user
umask 006

# Add /home/<username>/usercommands to the end of the PATH env var
export PATH=$PATH:/home/$USER/usercommands

# Print the current date on screen in ISO 8601 format
echo "The current date is: $(date -u +'%Y-%m-%dT%H:%M:%S+00:00')"

# Define a command alias for ltxt
alias ltxt='ls *.txt'

# Create ~/tmp directory if it doesn't exist, otherwise clean it
if [ -d ~/tmp ]; then
    rm -rf ~/tmp/*
else
    mkdir ~/tmp
fi

