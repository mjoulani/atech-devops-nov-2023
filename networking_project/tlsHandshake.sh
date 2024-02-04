#!/bin/bash

# Set the server address
SERVER="47.129.1.174:8080"

# Send a client hello request to the server
curl -s -X POST -H "Content-Type: application/json" -d '{"version": "1.3","ciphersSuites": ["TLS_AES_128_GCM_SHA256", "TLS_CHACHA20_POLY1305_SHA256"], "message": "Client Hello"}' http://$SERVER/clienthello> response.json

# Check if the request was successful
if [[ $? -ne 0 ]]; then
    echo "Something went wrong while sending REQUEST!"
    exit 5
fi

echo "Client hello Request sent successfully"

# Extract session ID and server certificate from the response
SESSION_ID=$(jq -r '.sessionID' response.json)
CERT=$(jq -r '.serverCert' response.json)

echo "Session has been started (session id: $SESSION_ID)"

# Save the server certificate to a file
echo "$CERT" > cert.pem

# Download the CA certificate
wget -q https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem -O cert-ca-aws.pem

# Check if CA certificate file exists
if [[ ! -f cert-ca-aws.pem ]]; then
    echo "Failed to get CA certificate!"
    exit 5
fi

# Set permissions for the certificate file
chmod 644 cert.pem

echo "Verifying certificate ..."

# Verify the server certificate against the CA certificate
openssl verify -CAfile cert-ca-aws.pem <(echo "$CERT")

if [[ $? -ne 0 ]]; then
    echo "Server Certificate is invalid."
    exit 5
fi

echo "Generating master key ..."

# Generate a random master key
MASTER_KEY=$(openssl rand -base64 32)

echo $MASTER_KEY > master-key.pem

echo "Encrypting master key ..."

# Encrypt the master key using the server certificate
ENC_KEY=$(echo "$MASTER_KEY" | openssl smime -encrypt -aes-256-cbc -outform DER <(echo "$CERT") | base64 -w 0)

msg_to_server="Hi server, please encrypt me and send to client!"
KEY_EXCHANGE()
{
	cat <<EOF
{
	"sessionID": "$SESSION_ID", 
	"masterKey": "$ENC_KEY",
	"sampleMessage": "$msg_to_server"
}
EOF
}

ENC_KEY_RES=$(curl -s -X POST -H "Content-Type: application/json" -d "$(KEY_EXCHANGE)" http://$SERVER/keyexchange)

encryptedSampleMessage=$(echo $ENC_KEY_RES | jq -r '.encryptedSampleMessage')

echo $encryptedSampleMessage | base64 -d > decodedMSG.txt

decrypted_txt=$(openssl enc -d -aes-256-cbc -pbkdf2 -in decodedMSG.txt -pass pass:"$MASTER_KEY")

if [[ "$msg_to_server" == "$decrypted_txt" ]]; then
  echo "Client-Server TLS handshake has been completed successfully"
else
  echo "Server symmetric encryption using the exchanged master-key has failed."
  exit 6
fi
