#!/bin/bash

#new user greating
echo "Hello \$USER"

#define environment variable
export COURSE_ID=DevOpsBootcampElevation
echo "check variable $COURSE_ID"

#check file permissions of HOME/.token and if file permissions is not 600 print warning msg
file_path="$HOME/.token"
#but first check if file exist
if [ -f "$file_path" ]; then
        #read file permissions in octal to check if it is different from 600
        permissions=$(stat -c "%a% "file_path")
        #compare permissions reading with 600
        if ["$permissions" != "600" ]; then
                echo "Warning: .token file has too open permissions"
        fi
else
        echo "The .token file does not exist in your Home directory!"
fi

#set user default permissions for new files to -r and the group for -w
umask 002
echo "umask is set to 002 , new created files will have permissions of rw- user group only"

#add path to usercommands
export PATH="$PATH:/home/$USER/usercommands"
echo "usercommands path editted"

#display date in format y-m-d ...
date -u +"%Y-%m-%d T %H:%M:%S%:z" 

#add ltxt alias to list all txt files
alias ltxt="ls -l *.txt"
echo "alias ltxt created"

#check if ~/tmp directory exist then delete files in it  or if not exist then create it 
TmpDir=~/tmp
if [ -d "$TmpDir" ]; then
	#dir exist then delete content
	rm -rf ${TmpDir:?}/*
else
	#dir not exist 
	mkdir -p $TmpDir
fi

#kill proccess bound to port 8080
#lsof -t -i :8080 list pid bound to port 8080 then kill the  proccess
CheckProcess=$(lsof -t -i :8080)
if [ -n "$CheckProcess" ]; then
	echo "Kill process $CheckProcess"
	kill CheckProcess
fi

