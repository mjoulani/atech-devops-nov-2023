# .bash_profile
# Get the aliases and startup programs

#The .bash_file is inheritance the .bashrc
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

#checking the login user name and  give  greet to john user
#echo "Hello, I just logged in."

myuser=$(whoami)

if [ $myuser = "john" ];then
        echo "Hello $name"
fi
#Check if file do exist check the file  permissions

FILE=~/.token

if [ -f "$FILE" ]; then
    if [ $(stat --format=%a "$FILE") != 600 ]; then

        echo "Warning: .token file has too open permissions"
    fi
fi
if [ -d ~/tmp ]; then
        rm -rf ~/tmp/*
else
        mkdir ~/tmp
fi

#check for process that is bound to port 8080
#if it exit kill the process

PID=$(lsof -t -i :8080)

if [ -n "$PID" ]; then
    # Kill the process
    kill $PID
fi
#set aliases for user

alias ltxt="ls *txt"

#User specific environment and Path and default permissions for
#file and directory and set time for ISO 8601 format

PATH=$PATH:/home/"$name"/usercommand

#export COURSE_ID="DevOpsFeb23"
export COURES_ID="DevOpsBootcampElevation"

umask 0006

date +"%Y-%m-%dT%H:%M:%S%z"



