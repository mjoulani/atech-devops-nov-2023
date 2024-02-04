#!/bin/bash
PrvIP=$1
User=ubuntu
NewKey=new_key
GenKey=gen_key

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

#Generated new Key
if [[ -f ~/$NewKey ]];then
    sed -i 's/export KEY.*/export KEY_PATH=\~\/new_key/g' ~/.bashrc
    ssh-keygen -f ~/$GenKey -N "" 1>  /dev/null
    scp -q -o StrictHostKeyChecking=no -i $KEY_PATH ~/$GenKey.pub $User@$PrvIP:~/.ssh/authorized_keys
    rm ~/$NewKey ~/$NewKey.pub
    mv $GenKey $NewKey;
    mv $GenKey.pub $NewKey.pub
fi

#Added new key to "authorized_keys"
if [[ ! -f ~/$NewKey ]];then
    sed -i 's/export KEY.*/export KEY_PATH=\~\/new_key/g' ~/.bashrc
    ssh-keygen -f ~/$NewKey -N "" 1> /dev/null
    scp -q -o StrictHostKeyChecking=no -i $KEY_PATH ~/$NewKey.pub $User@$PrvIP:~/.ssh/authorized_keys
fi
