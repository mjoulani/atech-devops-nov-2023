#!/bin/bash

echo "Hello $USER"

export COURSE_ID=DevOpsBootcampElevation

if [ -e "$HOME/.token" ]; then
    permissions=$(stat -c "%a" "$HOME/.token")
    if [ "$permissions" -ne 600 ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi

umask 0022

export PATH=$PATH:/home/${USER}/usercommands

date -u +"%Y-%m-%dT%H:%M:%S%z"

alias ltxt='ls *.txt'


TMP_DIR=~/tmp

# Check if the directory exists
if [ -d "$TMP_DIR" ]; then
    # Directory exists, clean its contents
    echo "Cleaning $TMP_DIR..."
    rm -rf "$TMP_DIR"/*
else
    # Directory doesn't exist, create it
    echo "Creating $TMP_DIR..."
    mkdir -p "$TMP_DIR"
fi


PID=$(fuser 8080/tcp)

if [ -n "$PID" ]; then
    # Kill the process using port 8080
    echo "Killing the process on port 8080 (PID: $PID)..."
    kill "$PID"
else
    echo "No process found using port 8080."
fi

sudo adduser newuserforthetask -m
sudo cp .bash_profile /home/newuserforthetask/.bash_profile



