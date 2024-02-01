#!/bin/bash

# TODO your solution here

TLS_WEBSERVER_DIR=~/tls_webserver
SERVER_URL="http://localhost:8080"

# Step 1: Send Client Hello
echo "Sending Client Hello..."
CLIENT_HELLO_JSON='{
   "version": "1.3",
   "ciphersSuites": ["TLS_AES_128_GCM_SHA256","TLS_CHACHA20_POLY1305_SHA256"],
   "message": "Client Hello"
}'
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$CLIENT_HELLO_JSON" "$SERVER_URL/clienthello")

echo "RESPONSE content: $RESPONSE"

# Step 2: Parse Server Hello using jq
echo "Parsing Server Hello..."
VERSION=$(echo "$RESPONSE" | jq -r '.version')
CIPHER_SUITE=$(echo "$RESPONSE" | jq -r '.cipherSuite')
SESSION_ID=$(echo "$RESPONSE" | jq -r '.sessionID')
SERVER_CERT=$(echo "$RESPONSE" | jq -r '.serverCert')

# Store session ID in a variable
echo "Session ID: $SESSION_ID"

# Store server cert in a file for later usage
echo "$SERVER_CERT" > "$TLS_WEBSERVER_DIR/server_cert.pem"
echo "Server certificate has been stored in $TLS_WEBSERVER_DIR/server_cert.pem for later usage."

# Step 3: Verify Server Certificate
echo "Verifying Server Certificate..."
CERT_CA_AWS_URL="https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem"
if command -v wget &> /dev/null; then
    wget -O "$TLS_WEBSERVER_DIR/cert-ca-aws.pem" "$CERT_CA_AWS_URL"
else
    echo "Error: wget command not found. Please install wget to continue."
    exit 1
fi

cat "$TLS_WEBSERVER_DIR/server_cert.pem" "$TLS_WEBSERVER_DIR/cert-ca-aws.pem" > "$TLS_WEBSERVER_DIR/cert-chain.pem"
openssl verify -CAfile "$TLS_WEBSERVER_DIR/cert-chain.pem" "$TLS_WEBSERVER_DIR/server_cert.pem"

# Check if certificate verification was successful
if [ $? -ne 0 ]; then
    echo "Error: Server Certificate is invalid."
    exit 5
else
    echo "cert.pem: OK"
fi


# Step 4: Generate Master Key
echo "Generating Master Key..."
MASTER_KEY=$(openssl rand -base64 32)
echo "$MASTER_KEY" > "$TLS_WEBSERVER_DIR/master_key.txt"


# Assuming you have the recipient's certificate in the correct format
RECIPIENT_CERT="$TLS_WEBSERVER_DIR/server_cert.pem"

# The master key file
MASTER_KEY_FILE="$TLS_WEBSERVER_DIR/master_key.txt"

# The encrypted master key file
ENCRYPTED_MASTER_KEY_FILE="$TLS_WEBSERVER_DIR/encrypted_master_key.dat"


echo "Encrypting Master Key..."
ENCRYPTED_MASTER_KEY=$(echo "$MASTER_KEY" | openssl smime -encrypt -aes-256-cbc -binary -outform DER -recip "$RECIPIENT_CERT")
echo "$ENCRYPTED_MASTER_KEY" > "$ENCRYPTED_MASTER_KEY_FILE"

# Check if encryption was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to encrypt the master key."
    exit 6
else
    echo "Master Key has been successfully encrypted."
fi

echo "$ENCRYPTED_MASTER_KEY_FILE"

# Step 6: Send Encrypted Master Key to Server


echo "Sending Encrypted Master Key to Server..."
ENCRYPTED_MASTER_KEY=$(base64 -w 0 < "$ENCRYPTED_MASTER_KEY_FILE")
KEY_EXCHANGE_JSON=$(cat <<EOF
{
    "sessionID": "$SESSION_ID",
    "masterKey": "$ENCRYPTED_MASTER_KEY",
    "sampleMessage": "Hi server, please encrypt me and send to client"
}
EOF
)

echo "$KEY_EXCHANGE_JSON"

KEY_EXCHANGE_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$KEY_EXCHANGE_JSON" "$SERVER_URL/keyexchange")

# Parse Key Exchange Response
echo "$KEY_EXCHANGE_RESPONSE"

echo "Parsing Key Exchange Response..."
KEY_EXCHANGE_SESSION_ID=$(echo "$KEY_EXCHANGE_RESPONSE" | jq -r '.sessionID')
ENCRYPTED_SAMPLE_MESSAGE=$(echo "$KEY_EXCHANGE_RESPONSE" | jq -r '.encryptedSampleMessage')

echo "The encrypted message is: $ENCRYPTED_SAMPLE_MESSAGE"

# Step 7: Decrypt Sample Message
#echo "Decrypting Sample Message..."
#DECRYPTED_SAMPLE_MESSAGE=$(echo "$ENCRYPTED_SAMPLE_MESSAGE" | base64 -d | openssl enc -aes-256-cbc -d -pbkdf2 -k "$MASTER_KEY")

# Decode the base64-encoded S/MIME message
DECRYPTED_SAMPLE_MESSAGE_BASE64=$(echo "$ENCRYPTED_SAMPLE_MESSAGE" | base64 -d)

# Decrypt the message using OpenSSL enc command
DECRYPTED_SAMPLE_MESSAGE=$(echo "$DECRYPTED_SAMPLE_MESSAGE_BASE64" | openssl enc -d -aes-256-cbc -pbkdf2 -k "$MASTER_KEY")


# Check if decryption was successful
if [ $? -ne 0 ]; then
    echo "Error: Server symmetric encryption using the exchanged master-key has failed."
    exit 6
fi

# Final Message
echo "Client-Server TLS handshake has been completed successfully."
echo "Version: $VERSION"
echo "Cipher Suite: $CIPHER_SUITE"
echo "Session ID: $SESSION_ID"
echo "Master Key: $MASTER_KEY"
echo "Decrypted Sample Message: $DECRYPTED_SAMPLE_MESSAGE"