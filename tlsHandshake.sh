#!/bin/bash


set -x # Enable debugging to see what commands are being executed


# Define server and CA details
SERVER_IP="3.36.52.31"
SERVER_PORT="8080"
CA_CERT_URL="https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem"
CA_CERT_FILE="cert-ca-aws.pem"
SERVER_ENDPOINT="http://$SERVER_IP:$SERVER_PORT"


# Step 1: Send Client Hello
RESPONSE=$(curl -s -X POST "$SERVER_ENDPOINT/clienthello" -H "Content-Type: application/json" -d '{
   "version": "1.3", 
   "cipherSuites": [ 
     "TLS_AES_128_GCM_SHA256", 
     "TLS_CHACHA20_POLY1305_SHA256"
   ],
  "message": "Client Hello" 
 }') 

echo "Client Hello Response: $RESPONSE"

SESSION_ID=$(echo "$RESPONSE" | jq -r '.sessionID') 
SERVER_CERT=$(echo "$RESPONSE" | jq -r '.serverCert')
echo "$SERVER_CERT" > server_cert.pem

# Step 2: Server Hello processed above, moving on to verify server certificate
wget -q "$CA_CERT_URL" -O "$CA_CERT_FILE"
openssl verify -CAfile "$CA_CERT_FILE" server_cert.pem > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Server Certificate is invalid."
    exit 5
fi


echo "Server Certificate verified successfully."


# Step 3: Generate Master Key and encrypt it with the server's public key
MASTER_KEY=$(openssl rand -base64 32)
echo "$MASTER_KEY" > master_key.txt
ENCRYPTED_MASTER_KEY=$(openssl smime -encrypt -aes-256-cbc -in master_key.txt -outform DER server_cert.pem | base64 -w 0)


# Step 4: Key Exchange
EXCHANGE_RESPONSE=$(curl -s -X POST "$SERVER_ENDPOINT/keyexchange" -H "Content-Type: application/json" -d "{ 
      \"sessionID\": \"$SESSION_ID\", 
      \"masterKey\": \"$ENCRYPTED_MASTER_KEY\", 
      \"sampleMessage\": \"Hi server, please encrypt me and send to client\"
      }")
      

ENCRYPTED_SAMPLE_MESSAGE=$(echo "$EXCHANGE_RESPONSE" | jq -r '.encryptedSampleMessage')

# Step 5: Decrypt and Verify Server Message
echo "$ENCRYPTED_SAMPLE_MESSAGE" | base64 -d > encrypted_sample_message.bin
openssl enc -d -aes-256-cbc -in encrypted_sample_message.bin -out decrypted_sample_message.txt -pass file:master_key.txt 


DECRYPTED_CONTENT=$(cat decrypted_sample_message.txt)

if [ "$DECRYPTED_CONTENT" = "Hi server, please encrypt me and send to client!" ]; then 
    echo "Client-Server TLS handshake has been completed successfully."
else
    echo "Server symmetric encryption using the exchanged master-key has failed."
    exit 6 
fi
