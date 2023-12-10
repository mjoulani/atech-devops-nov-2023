# get the user
echo "Hello $USER"
# Define an environment variable
export COURSE_ID=DevOpsBootcampElevation
# Checking for .token file
if [ -f ~/.token ]; then
    if [[ $(stat -c '%a' ~/.token) -ne 600 ]]; then
        echo 'Warning: .token file has too open permissions'
    fi
fi
# Change umask to set default permissions for new files
umask 0006
# Check directory permissions
if [[ ! -d ~/usercommands ]];then
   mkdir ~/usercommands
fi
# Add directory to PATH
export PATH="$PATH:/home/$USER/usercommands"
# print the date
date -u +"%Y-%m-%dT%H:%M:%S%:z"
# edit file txt
alias ltxt="ls *.txt"
# check directory tmp
if [[ ! -d ~/tmp ]];then
   mkdir ~/tmp
else 
    rm -rf ~/tmp/*
fi
# Find the process ID (PID) using port 8080
pid=$(sudo lsof -t -i:8080)
# If a process is found, kill it
if [ -n "$pid" ]; then
   sudo kill $pid
   echo "Killed port 8080"
fi
