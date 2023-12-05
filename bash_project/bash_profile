# Greet the user
echo "Hello $USER"

# Define environment variable
export COURSE_ID=DevOpsBootcampElevation

# Check .token file permissions
if [ -e ~/.token ]; then
    PERMISSIONS=$(stat -c "%a" ~/.token)
    if [ "$PERMISSIONS" != "600" ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi

# Change umask for default file permissions
umask 0077

# Add usercommands directory to PATH
export PATH=$PATH:/home/$USER/usercommands

# Print current date in ISO 8601 format
echo "The current date is: $(date -u +'%Y-%m-%dT%H:%M:%S%:z')"

# Define command alias for ltxt
alias ltxt='ls *.txt'

# Create or clean ~/tmp directory
[ -d ~/tmp ] && rm -rf ~/tmp || mkdir ~/tmp

# Kill process bound to port 8080 if it exists
fuser -k 8080/tcp > /dev/null 2>&1

