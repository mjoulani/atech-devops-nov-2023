# Greet the User
echo "Hello $USER"

# Define an environment variable
export COURSE_ID=DevOpsBootcampElevation

: '
stat: Is used to display information about the file
-c "%a": Specifies the format for the output. "%a" represents the file permissions in octal format.
'

# Check the permissions
permissions=$(stat -c %a ~/.token)

if [ "$permissions" -ne  600 ]; then
    echo "Warning: .token file has too open permissions"
fi

# Set the default permissions of newly created files to read and write for the user only
umask 0006

# Add /home/<username>/usercommands to the end of the PATH environment variable
export PATH=$PATH:/home/$USER/usercommands

# Print the current date in ISO 8601 format
echo "Current date: $(date -u +"%Y-%m-%dT%H:%M:%S%:z")"

# Define an alias
alias ltxt='ls *.txt'

# Check the existence of the temp directory and remove its content if it exists
temp_dir=~/tmp

if [ -d "$temp_dir" ]; then
    rm -rf "$temp_dir"/*
else
    mkdir -p "$temp_dir"
fi

: '
lsof: list open files - it provides information about files opened by processes
-Pi : 8080 : specify the protocol ("i"), the port (:8080), and disable hostname resolution (-P) "it will check the processes using port 8080"
-sTCP:LISTEN : to show the entries where the protocol is TCP and the state is Listen
-t : tells lsof to display the process IDs
'

# Check if a process is listening on port 8080 and kill it
if lsof -Pi :8080 -sTCP:LISTEN -t &> /dev/null; then
    echo "Killing the process bound to port 8080..."
    kill -9 $(lsof -Pi :8080 -sTCP:LISTEN -t)
    echo "Process killed."
fi
