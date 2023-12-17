#!/bin/bash
# .bash_profile

USER=$(whoami)
echo "Hello $USER"

export COURSE_ID="DevOpsBootcampElevation"

# Get file path
token_file="$HOME/.token"

if [[ -e "$token_file" && $(stat -c %a "$token_file") != 600 ]]; then
  echo "Warning: .token file has too open permissions"
fi

umask 600

export PATH="$PATH:/home/$USER/usercommands"

current_date=$(date -u +"%Y-%m-%dT%H:%M:%S%z")
echo "Current date:  $current_date"

alias ltxt="ls *.txt"

tmp_dir="$HOME/tmp"
if [[ -d "$tmp_dir" ]]; then
    find "$tmp_dir" -mindepth 1 -delete
fi
    echo "Directory $tmp_dir does not exist."
fi
if [[ ! -d "$tmp_dir" ]]; then
    mkdir "$tmp_dir"
else
    rm -rf "$tmp_dir/*"
fi

process_id=$(lsof -t -i:8080)
if [[ -n "$process_id" ]]; then
    kill "$process_id"
pid=$(lsof -ti tcp:8080 | head -n 2 | tail -n 1)
if [[ ! -z "$pid" ]]; then
  kill "$pid"
fi
alias ltxt='ls *.txt'
