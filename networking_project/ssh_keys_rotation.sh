#!/bin/bash
private_ip=$1
echo "private_ip: $private_ip"

newkey="your_key_filename"  # Replace with your desired key filename

if [[ -z $KEY_PATH ]];then
   echo "KEY_PATH variable not found."
   exit 5
fi

if [[ -z $private_ip ]];then
  echo "Please provide IP address!!"
  exit 5
fi

if [[ ! -f ~/$newkey ]]; then
    ssh-keygen -f ~/$newkey -t rsa -N '' <<< "y" 1> /dev/null
fi

chmod 600 ~/$newkey.pub
scp -o StrictHostKeyChecking=no -i $KEY_PATH ~/$newkey.pub $user@$private_i>
if [[ -f ~/$newkey ]]; then
    mv ~/$newkey{,.bak}
    ssh-keygen -f ~/$newkey -t rsa -N '' <<< "y" 1> /dev/null
    scp -o StrictHostKeyChecking=no -i ~/$newkey.bak ~/$newkey.pub $user@$p>    rm ~/$newkey.bak
fi

