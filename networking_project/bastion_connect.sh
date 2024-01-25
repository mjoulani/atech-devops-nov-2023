#!/bin/bash
expot KEY_PATH
read -s KEY_PATH < PATH.txt

public_key=$1
private_key=$2
if [ -z "$1" ];then
echo "Please provide bastion IP address"
exit 5
fi
if [ -z "$KEY_PATH" ];then
echo "KEY_PATH env var is expected"
exit 5
fi
ssh-add $KEY_PATH
if [ ! -z "$3" ]; then
    ssh -t -A ubuntu@$public_key "ssh ubuntu@$private_key '$3'"
elif [ ! -z "$2" ]; then
    ssh -t -A ubuntu@$public_key "ssh ubuntu@$private_key"
elif [ -z "$2" ]; then
    ssh -t -A ubuntu@$public_key
fi

#ssh -t -i $KEY_PATH ubuntu@$public_ins ". connect.sh "