#print hello to user
echo "Hello $USER"

#ENV variable
export COURSE_ID="DevOpsBootcampElevation"

##check if the token file exists and if it has the right permissions
if [[ -f ~/.token ]];then
	test $(stat -c "%a" ~/.token) -eq 600 || echo "Warning: .token file has too open permissions"
fi

##set the umask to read and write for the user and group
umask 0006


## check if the directory exists and add it to the PATH variable, if it does not exist create it
if [[ -d ~/usercommands ]];then
   export PATH=$PATH:~/usercommands
else
   mkdir ~/usercommands
fi

## output the date
date --iso-8601=seconds


## alias to print all files
alias ltxt="ls *.txt"


##create ~/tmp if it doesnt exist and clean it each time i log in
if [[ ! -d ~/tmp ]];then
   mkdir ~/tmp
else
  rm -r ~/tmp/* 2> /dev/null
fi


## kill processes attached to 8080
portsToKill=$(sudo netstat -tnlp | grep 8080 | awk '{print $7}' | cut -d'/' -f1)
for i in $portsToKill;do sudo kill $i;done

