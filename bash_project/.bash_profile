#!/bin/bash

echo "Hello $USER"

export COURSE_ID="DevOpsBootcampElevation"

echo $COURSE_ID

if [[ -e "$HOME/.token" ]; then
  permissions =$(stat -c "%a" "$HOME/.token")
  if [ "permissions" -ne 600 ]; then
     echo "Warning: .token file has too open permissions"
  fi
fi

umask 0006

export PATH=$PATH:/home/$USER/usercommands

date -u + "%Y-%m-%dT%H:%M:%S%z"


shopt -s expand_aliases
alias ltxt="ls | grep *.txt"

if [ -d ~/tmp ]; then
  rm -rf ~/tmp/*
else
  mkdir -p ~/tmp
fi

PID = $(fuser 8080/tcp)

if [ -n "$PID"]; then
   echo "killing the process on port 8080 (PID: $PID).."
   kill "$PID"
else
   echo "no process found using port 8080"
fi
