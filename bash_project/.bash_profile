#!/bin/bash

echo "Hello $USER"

export COURSE_ID="DevOpsBootcampElevation"

# Check and set the permissions for the .token file
token_file="$HOME/.token"

if [ -e "$token_file" ]; then
    if [ "$(stat -c '%a' "$token_file")" -ne 600 ]; then
        echo 'Warning: .token file has too open permissions'
        chmod 600 "$token_file"
        echo 'Permissions set to 600.'
    fi
fi

# Set the umask to read and write for the user and group
umask 0006

# Get the current username
username=$(whoami)

# Ensure the usercommands directory exists
usercommands_dir="/home/$username/usercommands"
mkdir -p "$usercommands_dir"

# Add the directory to the end of the PATH
echo "export PATH=\$PATH:$usercommands_dir" >> ~/.bashrc
source ~/.bashrc  # Apply changes to the current session

echo "The directory $usercommands_dir has been added to the end of the PATH variable."

# Print the current date
date -u +"The current date is: %Y-%m-%dT%H:%M:%S%z"

# Define the alias for ltxt in .bashrc
echo "alias ltxt='ls -al ~/tmp/*.txt'" >> ~/.bashrc
source ~/.bashrc  # Apply changes to the current session

# Ensure ~/tmp directory exists or clean it
tmp_dir="$HOME/tmp"
if [ -d "$tmp_dir" ]; then
    rm -rf "$tmp_dir"/*
else
    mkdir -p "$tmp_dir"
fi

echo "The directory $tmp_dir has been created or cleaned."

# Kill the process bound to port 8080 if it exists
if lsof -i :8080 >/dev/null 2>&1; then
    echo "Killing the process bound to port 8080"
    fuser -k 8080/tcp
fi
