#!/bin/bash
#TODO generate new certificate, make autherization file , scp autherization file to private virtual
#TODO ssh-keygen -t rsa -b 2048 -f ~/new_key

#Check Parameters
if [ -z "$KEY_PATH" ]; then
    echo "Error: KEY_PATH environment variable is not set."
    exit 5
fi
if [ $# -lt 1 ] || [ $# -gt 2 ] ; then
    echo "Usage: $0 <public-instance-ip> [<private-instance-ip>] "
    exit 5
fi
#Variables
public_instance_ip=$1
private_instance_ip=$2
#Backup OLD Access
ssh -i $KEY_PATH ubuntu@$public_instance_ip cp .ssh/authorized_keys authorized_keys.back
if [ $? -ne 0 ]; then
    echo "Error: cant make rotation ."
    exit 1
fi
#Generate New Key

ssh-keygen -t rsa -b 2048 -f ~/new_key -q -N ""
echo "sshkeygen pass"

NEW_PUBLIC_KEY=$(<~/new_key.pub)

ssh-keygen -y -f $KEY_PATH > ~/pub


OLD_PUBLIC_KEY=$(<~/pub)

scp -i $KEY_PATH "ubuntu@$public_instance_ip:~/.ssh/authorized_keys" ~/

sed -i "s|$OLD_PUBLIC_KEY|$NEW_PUBLIC_KEY|" ~/authorized_keys


# copy new authorized_keys to public then to private
scp -i $KEY_PATH ~/authorized_keys "ubuntu@$public_instance_ip:~/"
echo "copy authorized_keys file to public server done"
scp -i $KEY_PATH ~/new_key "ubuntu@$public_instance_ip:~/"
echo "copy new_key file to public server done"
scp -i $KEY_PATH "$KEY_PATH" "ubuntu@$public_instance_ip:~/old"
ssh -i $KEY_PATH ubuntu@$public_instance_ip "scp -i ~/old ~/authorized_keys ubuntu@$private_instance_ip:~/.ssh/"
echo "copy authorized_keys  file to private ssh directory server done"
scp -i $KEY_PATH ~/authorized_keys "ubuntu@$public_instance_ip:~/.ssh/"
echo "copy authorized_keys  file to public ssh directory server done"



#Optional : chmod 400 new_key

#export KEY_PATH=~/new_key