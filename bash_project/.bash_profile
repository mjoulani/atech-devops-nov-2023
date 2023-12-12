#!/bin/bash

echo "Hello $USER"

export COURSE_ID="DevOpsBootcampElevation"

FILE="$HOME/.token"
if [[ -e "$FILE" && $(stat -c %a "$FILE") != 600 ]]; then
  echo "Warning: .token file has too open permissions"
fi

umask 0006

export PATH=$PATH+":/home/$USER/usercommands"

time=$(date '+%Y-%m-%dT%H:%M:%S%z')
echo "${time:0:-2}:${time:(-2)}"

shopt -s expand_aliases
alias ltxt="ls | grep *.txt"

if [ -d ~/tmp ]; then
  rm -rf ~/tmp/*
else
  mkdir ~/tmp
fi

pid=$(sudo lsof -t -i:8080)
! [[ $pid == "" ]] && kill -9 "$pid" || echo "There is no Process run on port 8080"