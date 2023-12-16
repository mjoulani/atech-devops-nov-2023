# Greet the user
echo "Hello $USER"

# Define environment variable
export COURSE_ID="DevOpsBootcampElevation"

# Check .token file permissions
if [ -e ~/.token ]; then
    TOKEN_PERM=$(stat -c "%a" ~/.token)
    if [ "$TOKEN_PERM" != "600" ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi

# Set umask for user and group
umask 0077

# Add usercommands to PATH
export PATH="$PATH:/home/$USER/usercommands"

# Print current date in ISO 8601 format
echo "The current date is: $(date -u +"%Y-%m-%dT%H:%M:%S%:z")"

# Command alias for ltxt
alias ltxt='ls -1 | grep *.txt'

# Create or clean ~/tmp directory
tmp_dir=~/tmp

# Check if the directory exists
if [ -d "$tmp_dir" ]; then
    # If it exists, delete all contents
    rm -rf $tmp_dir/*
else
    # If it doesn't exist, create the directory
    mkdir $tmp_dir
fi

# Kill process bound to port 8080 if it exists
fuser -k 8080/tcp > /dev/null 2>&1