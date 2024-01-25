#!/bin/bash
#export KEY_PATH="/Users/hamadfyad/PycharmProjects/pythonProject522/5/a-tech_Project/atech-devops-nov-2023/networking_project/hamad_key.pem"
#export KEY_PATH
#read -s KEY_PATH < private_key.txt
#echo $KEY_PATH
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