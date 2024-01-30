#!/bin/bash
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
    ssh -t -i $KEY_PATH ubuntu@$public_ins "ssh -i bashar_z-privateKey.pem ubuntu@$private_ins"
    if [ $? -ne 0 ]; then
    ssh -t -i $KEY_PATH ubuntu@$public_ins "ssh -i new_key ubuntu@$private_ins"
    fi

else
    printing "Connecting to your private instance using the public instance to run a command '$command' in the private machine , please wait  .... "
    ssh -t -i $KEY_PATH ubuntu@$public_ins "ssh -i bashar_z-privateKey.pem ubuntu@$private_ins '$command'"
     if [ $? -ne 0 ]; then
       ssh -t -i $KEY_PATH ubuntu@$public_ins "ssh -i new_key ubuntu@$private_ins '$command'"
    fi
fi

# TODO your solution here
