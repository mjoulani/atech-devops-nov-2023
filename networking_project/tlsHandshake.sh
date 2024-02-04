#!/bin/bash

#Server Details
SERVER_IP=13.58.61.145
SERVER_PORT=8080

# Step 1 - Client Hello (Client -> Server)
client_hello="{\"version\": \"1.3\", \"ciphersSuites\": [\"TLS_AES_128_GCM_SHA256\", \"TLS_CHACHA20_POLY1305_SHA256\"], \"message\": \"Client Hello\"}"

echo "Step 1: Sending Client Hello to the server..."
server_response_json=$(curl -s -X POST -H "Content-Type: application/json" -d "$client_hello" http://$SERVER_IP:$SERVER_PORT/clienthello)

#Check if Client Hello was sent successfully
if [[ $? -eq 0 ]];then
 echo "Client Hello sent Successfully."
else
 echo "Failed to send Client Hello."
 exit 1
fi

# Step 2 - Server Hello (Server -> Client)
#Parse Server Hello JSON using jq
echo "Parsing Server Hello JSON..."
SERVER_VERSION=$(echo "$server_response_json" | jq -r '.version')
SERVER_ID=$(echo "$server_response_json" | jq -r '.sessionID')
SERVER_CERT=$(echo "$server_response_json" | jq -r '.serverCert')
echo "Parsing Server Hello JSON is DONE :)"

# saving server cert in a file
echo $SERVER_ID > cert.pem
echo "sessionID saved successfully inside cert.pem file"

#Step 3 - Server Certificate Verification
# Download the Certificate Authority (CA) file
wget https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem -O cert-ca-aws.pem

# Verify the server's certificate
echo "Verifying Server Certificate..."
openssl verify -CAfile cert-ca-aws.pem <(echo "$SERVER_CERT")

# Check if the certificate verification was successful
if [[ $? -eq 0 ]]; then
  echo "cert.pem: OK"
else
  echo "Server Certificate is invalid."
  exit 5
fi

#Step 4 - Client-Server master-key exchange
echo "Generating random master key..."
MASTER_KEY=$(openssl rand -base64 32)
#Encrypt master key using the server’s certificate
ENCRYPTED_MASTER_KEY=$(echo -n "$MASTER_KEY" | openssl smime -encrypt -aes-256-cbc -in <(echo "$MASTER_KEY") -outform DER <(echo "$SERVER_CERT") | base64 -w 0)

# Send encrypted master key to the server
echo "Sending encrypted master key to the server..."
server_response_json=$(curl -X POST -H "Content-Type: application/json" -d "{\"sessionID\": \"$SERVER_ID\", \"masterKey\": \"$ENCRYPTED_MASTER_KEY\", \"sampleMessage\": \"Hi server, please encrypt me and send to client!\"}" http://$SERVER_IP:$SERVER_PORT/keyexchange)
# Check if the request was successful
if [ $? -eq 0 ]; then
  echo "Encrypted master key sent successfully."
else
  echo "Failed to send encrypted master key."
  exit 1
fi

#Step 5 - Server verification message
# Parse Server Response JSON using jq
SERVER_VERIFICATION_SESSION_ID=$(echo "$server_response_json" | jq -r '.sessionID')
ENCRYPTED_SAMPLE_MESSAGE=$(echo "$server_response_json" | jq -r '.encryptedSampleMessage')
# Decrypt the encrypted sample message
echo "Decrypting the sample message..."
echo "$ENCRYPTED_SAMPLE_MESSAGE" | base64 -d > encSampleMsgReady.txt

#Step 6 - Client verification message
# Verify the decrypted sample message
EXPECTED_SAMPLE_MESSAGE="Hi server, please encrypt me and send to client!"
DECRYPTED_SAMPLE_MESSAGE=$(openssl enc -aes-256-cbc -d -in encSampleMsgReady.txt -k $MASTER_KEY -pbkdf2)
if [ "$DECRYPTED_SAMPLE_MESSAGE" == "$EXPECTED_SAMPLE_MESSAGE" ]; then
  echo "Client-Server TLS handshake has been completed successfully."
else
  echo "Server symmetric encryption using the exchanged master-key has failed."
  exit 6
fi
