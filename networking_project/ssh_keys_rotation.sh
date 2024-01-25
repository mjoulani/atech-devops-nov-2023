#!/bin/bash
#TODO generate new certificate, make autherization file , scp autherization file to private virtual
#TODO ssh-keygen -t rsa -b 2048 -f ~/new_key

#Check Parameters
if [ -z "$KEY_PATH" ]; then
    echo "Error: KEY_PATH environment variable is not set."
    exit 5
fi

if [ $# -lt 1 ] || [ $# -gt 2 ] ; then
    echo "Please provide IP address"
    exit 5
fi
#Variables
NEW_PUBLIC_KEY="~/new_key.pub"
private_instance_ip=$1
#Generate New Key
ssh-keygen -t rsa -b 2048 -f ~/new_key -q -N ""
# Get auth key
scp -i $KEY_PATH "$private_instance_ip:~/.ssh/authorized_keys" "."
#change Key
ssh-keygen -y -f $KEY_PATH > pub
OLD_PUBLIC_KEY=$(<pub)
sed -i "s|$OLD_PUBLIC_KEY|$NEW_PUBLIC_KEY|" "authorized_keys"

#Copy key to remote server and overright the old access
scp -i $KEY_PATH authorized_keys ubuntu@$private_instance_ip:~/.ssh/


#Optional : chmod 400 new_key

export KEY_PATH=~/new_key
