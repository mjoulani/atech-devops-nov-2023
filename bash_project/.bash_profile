 #.bash_profile
# Get the aliases and startup programs


#The .bash_file is inheritance the .bashrc
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

#checking the login user name and  give  greet to john user
user=$(whoami)
echo "Hello $user"

#Check if file do exist check the file  permissions

FILE=~/.token

if [ -f "$FILE" ]; then
    if [ $(stat --format=%a "$FILE") != 600 ]; then
            echo "Warning: .token file has too open permissions"
    fi
fi

#Checking if the directory exist and delete all the contains of the directory
#If the directory dose not exit it will create this directory in user home


if [ -d ~/tmp ]; then
        rm -r -f tmp/*
else
        mkdir ~/tmp
fi
if [ $? -eq 0 ]; then
        kill -9 $(lsof -t -i:8080)
        echo "port in use and stopped"
fi

if [[ ! -d ~/usercommands ]];then
   mkdir ~/usercommands
fi

#set aliases for user

alias ltxt="ls *txt"

#User specific environment and Path and default permissions for

PATH=$PATH:/home/"$user"/usercommands
export COURSE_ID="DevOpsBootcampElevation"
umask 0006
date +"%Y-%m-%dT%H:%M:%S%z"
echo "$COURSE_ID"




