#!/bin/bash

#greeting new user.
echo "Hello $USER"

#define environment variable
export COURSE_ID=DevOpsBootcampElevation

#check file permissions of HOME/.token and if file permissions is not 600 print warning msg
file_path="${HOME}/.token"
#but first check if file exist
if [ -e "$file_path" ]; then
        #read file permissions in octal to check if it is different from 600
        permissions=$(stat -c "%a" "$file_path")
        #compare permissions reading with 600
        if [ "$permissions" != "600" ]; then
                echo "Warning: .token file has too open permissions"
        fi
fi
#else
#        echo "The .token file does not exist in your Home directory!"
#fi

#set user default permissions for new files to -r and the group for -w
umask 006

#add path to usercommands
export PATH="$PATH:/home/${USER}/usercommands"

#display date in ISO format y-m-d ...
date +'%Y-%m-%dT%H:%M:%S%z'

#add ltxt alias to list all txt files
alias ltxt='ls -l *.txt'

#check if ~/tmp directory exist then delete files in it  or if not exist then create it 
TmpDir=${HOME}/tmp
if [ -d "$TmpDir" ]; then
	#dir exist then delete content
	#echo "TmpDir do exist...now deleting content"
	find "$TmpDir" -type f -delete
else
	#dir not exist
	#echo "TmpDir not exist...creating one"
	mkdir -p "$TmpDir"
fi

#kill proccess bound to port 8080
#lsof -t -i :8080 list pid bound to port 8080 then kill the  proccess
CheckProcess=$(sudo lsof -t -i :8080)

if [ -n "$CheckProcess" ]; then
	#echo "Kill process $CheckProcess"
	sudo kill $CheckProcess
fi
