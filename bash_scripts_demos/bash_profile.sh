# answer for 1.........................

sudo nano /etc/skel/.bash_profile

# Greet the user
echo "Hello $(whoami)"


# Define an environment variable COURSE_ID
export COURSE_ID=DevOpsBootcampElevation

# Check .token file permissions and print a warning if needed
if [ -e ~/".token" ]; then
    if [ $(stat -c "%a" ~/".token") -ne 600 ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi


# Change umask to set default permissions for new files
umask 0077

# Add usercommands directory to the end of the PATH env var
export PATH=\$PATH:/home/\$USER/usercommands

# Print the current date in ISO 8601 format
echo "The current date is: \$(date -u +'%Y-%m-%dT%H:%M:%S%z')"

# Define an alias for ltxt command
alias ltxt='ls *.txt'

# Create or clean the ~/tmp directory
if [ ! -d ~/tmp ]; then
    mkdir ~/tmp
else
    rm -rf ~/tmp/*
fi


# Kill the process bound to port 8080 if it exists
if lsof -i :8080; then
    kill $(lsof -t -i:8080)
fi



# answer for 2........................

sudo cp /etc/skel/.bash_profile /etc/skel/.bash_profile.backup

sudo nano /etc/skel/.bash_profile

sudo adduser newusername

su -l newusername


# answer for 3................................


# login for new user

su -l john

# enter password

 # hello john

 # check date
 date -u +"%Y-%m-%dT%H:%M:%S+00:00"

ltxt

echo $COURSE_ID

ls -l ~/tmp

echo $PATH

cp ~/.bash_profile /path/to/bash_project/.bash_profile
