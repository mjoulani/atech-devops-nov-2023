#!/bin/bash
# export KEY_PATH=~/Desktop/DevOps/atech-devops-nov-2023/networking_project/ofer-bakria-key.pem
public_ins="$1"
private_ins="$2"
command="$3"

printing () {
  echo "$1"
}

if [ -z "${KEY_PATH}" ]; then
    printing "KEY_PATH env var is expected"
    exit 5
fi

if [ "$#" -eq 0 ]; then
    printing "Please provide bastion IP address ."
    exit 5
elif [ "$#" -eq 1 ]; then
    printing "Connecting to your public instance , please wait  .... "
    ssh -t -i $KEY_PATH ubuntu@$public_ins
elif [ "$#" -eq 2 ]; then
    printing "Connecting to your private instance using the public instance , please wait  .... "
    ssh -t -i $KEY_PATH ubuntu@$public_ins "ssh -i ofer-bakria-key02.pem ubuntu@$private_ins"
else
    printing "Connecting to your private instance using the public instance to run a command '$command' in the private machine , please wait  .... "
    ssh -t -i $KEY_PATH ubuntu@$public_ins "ssh -i ofer-bakria-key02.pem ubuntu@$private_ins '$command'"
fi



# TODO your solution here
# scp -i /path/to/private-key your-local-file.txt user@remote-server:/path/on/remote-server/
# export KEY_PATH=~/Desktop/DevOps/atech-devops-nov-2023/networking_project/ofer-bakria-key.pem
# ssh -t -i $KEY_PATH ubuntu@$public_ins ". connect.sh 10.0.1.94"
