#!/bin/bash

echo "Hello $USER"


export COURSE_ID="DevOpsBootcampElevation"

TOKEN_FILE="$HOME/.token"
if [ -e "$TOKEN_FILE" ]; then
    PERMISSIONS=$(stat -c "%a" "$TOKEN_FILE")
    if [ "$PERMISSIONS" -ne 600 ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi

umask 0006

export PATH=$PATH:/home/$USER/usercommands

echo "The current date is: $(date -u +"%Y-%m-%dT%H:%M:%S%z")"

alias ltxt='ls *.txt'

TMP_DIR="$HOME/tmp"
if [ -e "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"/*
else
    mkdir "$TMP_DIR"
fi

fuser -k 8080/tcp
