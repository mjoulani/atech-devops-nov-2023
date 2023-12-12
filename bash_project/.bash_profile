#!/bin/bash

# Greet the user
username=$(whoami)
echo "Hello $username"

export COURSE_ID="DevOpsBootcampElevation"

# Get file path
token_file="$HOME/.token"

if [[ -e "$token_file" && $(stat -c %a "$token_file") != 600 ]]; then
  echo "Warning: .token file has too open permissions"
fi

umask 0006

# fix path separator
usercommands_path="/home/$username/usercommands"

# Add usercommands to PATH
export PATH="$PATH:$usercommands_path"

# Print the current date
date=$(date -u +"%Y-%m-%dT%H:%M:%S%:z")
echo "Current date: $date"

# Fix alias definition
alias ltxt="ls *.txt"

# Managing tmp directory
if [ ! -d ~/tmp ]; then
    mkdir ~/tmp
else
    rm -rf ~/tmp/*
fi


# Get process ID with proper sanitization
pid=$(lsof -ti tcp:8080 | head -n 2 | tail -n 1)

# Check if a process ID was found
if [[ ! -z "$pid" ]]; then
  kill "$pid"
fi