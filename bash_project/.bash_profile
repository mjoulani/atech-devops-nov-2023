#!/bin/bash
echo -n "Enter your name: "  # don't begin a new line while taking the name input (-n)
read name
echo "Hello, $name"

COURSE_ID="DevOpsBootcampElevation"

# Check if the .token file in the home directory
token_file="/home/$USER/.token"  # Use $USER to get the current user's username

if [ -e "$token_file" ]; then
    # Check the file permissions
    permissions=$(stat -c "%a" "$token_file")

    if [ "$permissions" -ne 600 ]; then
        echo "Warning: $token_file file has too open permissions"

        # Changing the umask for the user
        umask 0077
        echo "Umask changed successfully."
    fi
else
    echo "Error: $token_file not found."
fi

# Add /home/<username>/usercommands to the end of the PATH
export PATH=$PATH:/home/$USER/usercommands
echo "PATH modified. Now it includes /home/$USER/usercommands."

date -u +"%Y-%m-%dT%H:%M:%S%:z"

alias ltxt='ls -a *.txt'

# Function to create or clean ~/tmp directory
function cleantmp() {
    tmp_dir="$HOME/tmp"

    # Check if the directory exists
    if [ -d "$tmp_dir" ]; then
        # If it exists, clean it (delete all contents)
        echo "Cleaning $tmp_dir..."
        rm -rf "$tmp_dir"/*
    else
        # If it doesn't exist, create it
        echo "Creating $tmp_dir..."
        mkdir -p "$tmp_dir"
    fi

    echo "Operation completed."
}

# Alias to call the cleantmp function
alias cleantmp=cleantmp

# Function to kill the process bound to port 8080
function killport() {
    port=8080

    # Check if the port is in use
    if lsof -i :$port > /dev/null; then
        # If it is, kill the process
        echo "Killing process bound to port $port..."
        lsof -i :$port | awk 'NR!=1 {print $2}' | xargs kill
        echo "Process killed."
    else
        echo "No process found on port $port."
    fi
}

# Alias to call the killport function
alias killport=killport