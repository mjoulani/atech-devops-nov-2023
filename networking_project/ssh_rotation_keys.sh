#!/bin/bash

#echo $KEY_PATH
# export KEY_PATH=~/ofer-bakria-key02.pem

if [ -z "${KEY_PATH}" ]; then
    echo "KEY_PATH env var is expected"
    exit 5
fi

if [ "$#" -eq 0 ]; then
    echo "Please provide IP address"
    exit 5
fi

old_key="ofer-bakria-key02.pem"
new_key="test04.pem"
private_ins=$1
ssh-keygen -t rsa -N "" -f $new_key <<<y >/dev/null 2>&1

scp -i "$old_key" $new_key.pub ubuntu@$private_ins:~/.ssh/authorized_keys >/dev/null 2>&1

cp test04.pem "$old_key"
