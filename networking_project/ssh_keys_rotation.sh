#!/bin/bash
PrvIP=$1
User=ubuntu
NewKey=new_key

#CheckCase1
if [[ -z $KEY_PATH ]];then
    echo "KEY_PATH variable not found"
    exit 5
fi

#CheckCase2
if [[ -z $PrvIP ]];then
    echo "Please provide IP address"
    exit 5
fi

if [[ ! -f ~/$NewKey ]];then
    ssh-keygen -f ~/$NewKey -t rsa -N ''<<< "y"  1> /dev/null
    chmod 600 ~/$NewKey.pub
    scp -o StrictHostKeyChecking=no -i $KEY_PATH ~/$NewKey.pub $User@$PrvIP:~/.ssh/authorized_keys 1> /dev/null 2> /dev/null

elif [[ -f ~/$NewKey ]];then
    mv ~/$NewKey ~/$NewKey.bak
    ssh-keygen -f ~/$NewKey -t rsa -N ''<<< "y"  1> /dev/null
    scp -o StrictHostKeyChecking=no -i ~/$NewKey.bak ~/$NewKey.pub $User@$PrvIP:~/.ssh/authorized_keys 1> /dev/null 2> /dev/null
    rm ~/$NewKey.bak
fi