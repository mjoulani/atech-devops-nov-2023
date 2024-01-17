#!/bin/bash



function check_string {
    local str="$1"
    if ! [[ $str =~ [[:alpha:]] && $str =~ [[:digit:]] && $str =~ "@" ]];  then
        echo "String '$str' is invalid. It should contain @, at least one letter, and at least one number."
        echo "Example : $0  public_user1@example.com   private_user1@178.0.0.10"
        exit 5
    fi
}

#*************************************************************************************************************

# Check if the KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "Error: The KEY_PATH environment variable is not set."
    exit 5
fi

echo  "pass"





# Check if two arguments are provided
if [ "$#" -eq  0 ]; then
    echo "Please provide bastion IP address"
    echo "Please run the bastion_connect.sh in this form : $0 <public-instance-ip> <private-instance-ip>"
    exit 5
elif [ "$#" -eq  1 ]; then
        check_string "$1"
        ssh -i $PATH_KEY  "$1"
elif [ "$#" -eq  2 ]; then
        check_string "$1"
        check_string "$2"
        ssh -i $PATH_KEY -J  "$1" "$2"
elif [ "$#" -eq  3 ]; then
        check_string "$1"
        check_string "$2"
        ssh -i $PATH_KEY -J "$1" "$2" $3
else
         echo "The $0 can have only three argument"
         exit 5
fi
