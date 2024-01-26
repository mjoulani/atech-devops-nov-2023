#!/bin/bash

if_in_bashrc(){
  if [[ -n $(grep '^export KEY.*' .bashrc) ]];then
    echo 1
  fi
}


if [[ -f ~/new_key ]];then
   value=$(if_in_bashrc)
   if [[ $value -eq 1 ]];then
     sed -i 's/^export KEY.*/export KEY_PATH=~\/new_key/g' .bashrc
   else
     sed -i "1s/^/export KEY_PATH=~\/new_key\\n/" .bashrc
   fi
else
   value=$(if_in_bashrc)
   if [[ $value -eq 1 ]];then
     sed -i 's/^export KEY.*/export KEY_PATH=~\/key.pem/g' .bashrc
   else
     sed -i "1s/^/export KEY_PATH=\~\/key.pem\\n/" .bashrc
   fi

fi
