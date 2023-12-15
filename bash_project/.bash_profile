#!/bin/bash
#1.print username
echo "Hello $(whoami)"
echo
#2.define env variable
export COURSE_ID=DevOpsBootcampElevation

#3.check permissions of .token file
if [ ! -e ~/.token ]; then
    touch ~/.token
else
#make sure to change permissions to read and write for user only
  chmod u+rw ~/.token
fi
if [ ! $(stat -c %a ~/.token) -eq 600 ]; then
   echo "Warning: .token file has too open permissions"
fi
echo
#4. change the umask of the user
umask 117

#5. add /home/<username>/usercommands to the end of the PATH env variable
export PATH=$PATH:/home/$USER/usercommands

#6.print date
echo "The current date is: $(date --iso-8601=seconds)"
echo
#7.define a command alias
alias ltxt="ls *.txt"

#8. ~/tmp directory
if [ -e ~/tmp ]; then
   rm -rf ~/tmp/*
else
   mkdir ~/tmp
fi

#9.If it exists, kill the process that is bound to port 8080
lsof -i:8080 && kill -9 $(lsof -t -i:8080)

