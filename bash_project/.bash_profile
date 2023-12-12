echo "Hello $USER"
export COURSE_ID="DevOpsBootcampElevation"

# Check if the file exists
if [ -f ~/.token ]; then
    if [[ $(stat -c '%a' ~/.token) -ne 600 ]]; then
        echo 'Warning: .token file has too open permissions'
    fi
fi

##set the umask to read and write for the user and group
umask 0006

# Get the current username
username=$(whoami)

# Ensure the usercommands directory exists
usercommands_dir="/home/$username/usercommands"
mkdir -p "$usercommands_dir"

# Add the directory to the end of the PATH
echo "export PATH=\$PATH:$usercommands_dir" >> ~/.bashrc

echo "The directory $usercommands_dir has been added to the end of the PATH variable."

date -u +"The current date is : %Y-%m-%dT%H:%M:%S%z"

# Define the alias for ltxt
alias ltxt='ls -al ~/tmp/*.txt'

# Ensure ~/tmp directory exists or clean it
if [ -d ~/tmp ]; then
    rm -rf ~/tmp/*
else
    mkdir -p ~/tmp
fi

# Kill the process bound to port 8080 if it exists
if lsof -i :8080 >/dev/null 2>&1 ; then
    echo "Killing the process bound to port 8080"
    fuser -k 8080/tcp
fi
