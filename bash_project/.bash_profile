#!/bin/bash
# .bash_profile
echo "Hello $USER"
token_file="$HOME/.token"
if [ -e "$token_file" ]; then
    permissions=$(stat -c "%a" "$token_file")
    if [ "$permissions" -ne 600 ]; then
        echo "Warning $token_file file has to open permissions"
    fi
else
    echo "Warning: $token_file file does not exist"

fi

umask 006

export PATH="$PATH:/home/$(whoami)/usercommands"
current_date=$(date -u +"%Y-%m-%dT%H:%M:%S%z")

echo "Current date:  $current_date"
tmp_dir="$HOME/tmp"
if [ -d "$tmp_dir" ]; then
    rm -rf "$tmp_dir"/*
else
    mkdir "$tmp_dir"
fi
process_id=$(lsof -t -i:8080)
if [ -n "$process_id" ]; then
    kill "$process_id"
fi
alias ltxt='ls *.txt'
