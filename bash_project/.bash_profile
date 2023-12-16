#!/bin/bash
# .bash_profile
echo "Hello $USER"

export COURSE_ID="DevOpsBootcampElevation"

token_file="$HOME/.token"

if [[ -e "$token_file" && $(stat -c %a "$token_file") != 600 ]]; then
  echo "Warning: .token file has too open permissions"
fi

umask 007

export PATH="$PATH:/home/$USER/usercommands"

current_date=$(date -u +"%Y-%m-%dT%H:%M:%S%z")
echo "Current date:  $current_date"

tmp_dir="$HOME/tmp"
if [[ -d "$tmp_dir" ]]; then
    rm -rf "$tmp_dir"/*
else
    mkdir "$tmp_dir"
fi

process_id=$(lsof -t -i:8080)
if [[ -n "$process_id" ]]; then
    kill "$process_id"
fi

alias ltxt='ls *.txt'
