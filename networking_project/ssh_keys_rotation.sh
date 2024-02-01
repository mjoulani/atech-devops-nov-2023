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
if [[ ! -f ~/$newkey ]];then
ssh-keygen -f ~/$newkey -t rsa -N "" 1> /dev/null
chmod 600 ~/$newkey.pub
scp -o StrictHostKeyChecking=no -i $KEY_PATH ~/$newkey.pub $user@$private_ip:~/.ssh/authorized_keys 1> /dev/null 2> /dev/null
 elif [[ -f ~/$newkey ]];then
mv ~/$newkey ~/$newkey.bak
ssh-keygen -f ~/$newkey -t rsa -N "" 1> /dev/null
scp -o StrictHostKeyChecking=no -i ~/$newkey.bak ~/$newkey.pub $user@$private_ip:~/.ssh/authorized_keys 1> /dev/null 2> /dev/null
rm ~/$newkey.bak
fi

