#!/bin/bash
function check_string {
    local str="$@"
    if ! [[ $str =~ [[:alpha:]] && $str =~ [[:digit:]] && $str =~ "@" ]];  then
        echo "String '$str' is invalid. It should contain @, at least one letter, and at least one number."
        echo "Example : $0  private_user1@example.com   new key name for rotation"
        exit 0
    fi
}

#****************************************************************
# Check if the KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
    echo "Error: The KEY_PATH environment variable is not set."
    exit 0
fi
echo  "pass"
# Check if two arguments are provided
if [ "$#" -eq  0 ]; then
    echo "Please provide IP address"
    echo "Please run the ssh_key_rotation.sh in this form : $0 <private-instance-ip> <enter new key name>"
    exit 5
elif [ "$#" -eq 1 ]; then
        echo "Please enter name for the key after Hostname the $0 must have two argument"
        exit 5
elif [ "$#" -eq  2 ]; then
        check_string "$1"


else
         echo "The $0 can have only two argument"
         exit 0
fi
new_key="$2"
echo "pass level two"
# Check if the variables are equal
if [ "$2" == "$KEY_PATH" ]; then
    echo "The key name already exists please use other key name"
    exit 0
fi
echo "pass level three"
echo $new_key
echo $1

#********************************************************************
NEW_KEY_NAME="$2"

# Generate a new RSA key pair without a passphrase
openssl genpkey -algorithm RSA -out "$NEW_KEY_NAME.pem"

#openssl rsa -pubout -in "$NEW_KEY_NAME.pem" -out "$NEW_KEY_NAME.pub"
ssh-keygen -y -f "$NEW_KEY_NAME.pem"  > ~/"$NEW_KEY_NAME.pub"

chmod  400 "$NEW_KEY_NAME.pem"

# Define variables
PRIVATE_INSTANCE_IP="$1"
PRIVATE_INSTANCE_USER="ec2-user"
PRIVATE_KEY_PATH="$KEY_PATH"

# Copy the public key to the private instance
scp -i "$PRIVATE_KEY_PATH" "$NEW_KEY_NAME.pub" "$PRIVATE_INSTANCE_IP:~"
# Update the SSH authorized_keys file on the private instance
ssh -i "$PRIVATE_KEY_PATH" "$PRIVATE_INSTANCE_IP" << EOF
     cat "$NEW_KEY_NAME.pub" > ~/.ssh/authorized_keys
     rm "$NEW_KEY_NAME.pub"
EOF
