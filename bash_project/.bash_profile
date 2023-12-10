#!/bin/bash

#mession 1 - greet the user
echo "Hello $USER"
#Define an environment variable called COURSE_ID with value equal to DevOpsBootcampElevation.
export COURSE_ID=DevOpsBootcampElevation

#Check .token file permissions
if [ -e ~/.token ]; then
  permissions=$(stat -c %a ~/.token)
  if [ "$permissions" -ne 600 ]; then
    echo "Warning : .token file has too open permissions"
  fi
fi

  #change unmask for default file permissions
unmask 0077

# Add ~/usercommands to the end of PATH
export PATH=\$PATH:~/usercommands

#print the current date
echo "The current date is :\$(date -u +"%Y-%m-%dT%H:%M:%S%:z")"

#Define a command alias
alias ltxt='ls *.txt'

#Create or clean ~/tmp directory
[ -d ~/tmp ] && rm -rf ~/tmp
mkdir -p ~/tmp

#kil the precess bound to port 8080 if it exists
lsof -ti :80808 | xargs  -r kill -9
EOL
#change ownership and permissions
chown root:root /etc/skel/.bash_profile
chmod 755 /etc/skel/.bash_profile

#create a new user
sudo adduser newuser
