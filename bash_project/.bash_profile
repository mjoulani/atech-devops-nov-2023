#!/bin/bash
#1.print username
echo "Hello $(whoami)"
#2.define env variable
export COURSE_ID=DevOpsBootcampElevation

#3.check permissions of .token file
if [ ! -e ~/.token ]; then
    touch ~/.token
fi
  chmod u+rw ~/.token
if [ ! $(stat -c %a ~/.token) -eq 600 ]; then
   echo "Warning: .token file has too open permissions"
fi
#4. change the umask of the user
umask 117

#5. add /home/<username>/usercommands to the end of the PATH env variable
export PATH=$PATH:/home/$USER/usercommands

#6.print date
echo "The current date is: $(date --iso-8601=seconds)"
#7.define a command alias
alias ltxt="ls *.txt"

#8. ~/tmp directory
if [ -e ~/tmp ]; then
   rm -rf ~/tmp/*
else
   mkdir ~/tmp
fi

#9.kill the process that is bound to port 8080
lsof -i:8080 && kill -9 $(lsof -t -i:8080)