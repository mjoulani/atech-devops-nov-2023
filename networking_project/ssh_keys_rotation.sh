#!/bin/bash

if [[ -z $KEY_PATH ]]; then
        echo "KEY_PATH env must be provided"
        exit 5
fi

if [ $# -ne 1 ]; then
        echo "Private IP must be provided"
        exit 5
fi

PRIVATE_IP=$1
NEW_KEY_PATH=new_key

cd ~

if [ ! -e $NEW_KEY_PATH ]; then
        ssh-keygen -f "./$NEW_KEY_PATH" -N ""
        chmod 600 ./"$NEW_KEY_PATH" ./"$NEW_KEY_PATH.pub"
fi

scp -i "$KEY_PATH" "./$NEW_KEY_PATH.pub" ubuntu@$PRIVATE_IP:~/"$NEW_KEY_PATH.pub"

ssh -o StrictHostKeyChecking=no -i $KEY_PATH ubuntu@$PRIVATE_IP "cat ~/$NEW_KEY_PATH.pub > ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && rm -f ~/$NEW_KEY_PATH.pub "

