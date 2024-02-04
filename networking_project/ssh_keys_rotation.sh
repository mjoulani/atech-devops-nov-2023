#!/bin/bash
private_ip=$1
user=ubuntu
newkey=new_key


if [[ -z $KEY_PATH ]];then
    echo "KEY_PATH variable not found"
    exit 5
fi

if [[ -z $private_ip ]];then
    echo "Please provide IP address"
    exit 5
fi

if [[ -f ~/$newkey ]];then
    sed -i 's/export KEY.*/export KEY="\~/new_key"/' ~/.bashrc
    ssh-keygen -f ~/key1  -N "" 1>  /dev/null
    scp -q -o StrictHostKeyChecking=no -i $KEY_PATH ~/key1.pub $user@$private_ip:~/.ssh/authorized_keys
    rm ~/$newkey ~/$newkey.pub
    mv key1 $newkey;
    mv  key1.pub $newkey.pub
fi

if [[ ! -f ~/$newkey ]];then
    ssh-keygen -f ~/$newkey  -N "" 1>  /dev/null
    scp -q -o StrictHostKeyChecking=no -i $KEY_PATH ~/$newkey.pub $user@$private_ip:~/.ssh/authorized_keys
fi