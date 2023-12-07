echo "Hello $USER"
export COURSE_ID=DevOpsBootcampElevation

if [[ ! -f ~/.token ]];then
   echo "file does not exist"
   else
   perm=$(stat -c "%a" ~/.token)
   if [[ "$perm" -ne 600 ]];then
      echo "Warning : .token has too many open permissions"
   fi
   
fi


umask 0077

if [[ ! -d ~/usercommands ]];then
   mkdir ~/usercommands
fi

export PATH="$PATH:/home/$USER/usercommands"

date -u +"%Y-%m-%dT%H:%M:%S%:z"
alias ltxt="ls *.txt"

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
