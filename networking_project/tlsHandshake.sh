#!/bin/bash

#Client Hello HTTP request to the server and save specific keys from the JSON response
curl -X POST \
      http://13.232.224.75:8080/clienthello \
      -H "Content-Type: application/json" \
      -d '{"version":"1.3","ciphersSuites":["TLS_AES_128_GCM_SHA256","TLS_CHACHA20_POLY1305_SHA256"],"message":"Client Hello"}' \
      | jq -r '.serverCert' > cert.pem


#Client Hello HTTP request to the server and save specific keys from the JSON response
curl -X POST \
      http://13.232.224.75:8080/clienthello \
      -H "Content-Type: application/json" \
      -d '{"version":"1.3","ciphersSuites":["TLS_AES_128_GCM_SHA256","TLS_CHACHA20_POLY1305_SHA256"],"message":"Client Hello"}' \
      | jq -r '.sessionID' > sessionID.txt


# download Certificate Authority from Amazon Web Services
wget  https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem


#verify the certificate
VERIFICATION_RESULT=$( openssl verify -CAfile cert-ca-aws.pem cert.pem )
if [ "$VERIFICATION_RESULT" != "cert.pem: OK" ]; then
  echo "Server Certificate is invalid."
  exit 1
fi
#generate a 32 random bytes string
openssl rand -base64 32 > masterKey.txt
SESSION_ID=$(cat sessionID.txt)

MASTER_KEY=$(openssl smime -encrypt -aes-256-cbc  -in masterKey.txt -outform DER cert.pem | base64 -w 0)


#curl again an HTTP POST request to the server endpoint /keyexchange
curl -X POST \
      http://13.232.224.75:8080/keyexchange \
      -H "Content-Type: application/json" \
      -d '{"sessionID":"'${SESSION_ID}'","masterKey":"'${MASTER_KEY}'","sampleMessage":"Hi server, please encrypt me and send to client!"}'\
      | jq -r '.encryptedSampleMessage' > encryptedSampleMessage.txt  

#ncode it to binary
cat encryptedSampleMessage.txt | base64 -d  > encSampleMsgReady.txt

#decript massage
openssl enc -d -aes-256-cbc -pbkdf2  -kfile masterKey.txt -in encSampleMsgReady.txt -out dencryptedSampleMessage.txt

DECRYPTED_SAMPLE_MESSAGE=$(cat dencryptedSampleMessage.txt)

if [ "$DECRYPTED_SAMPLE_MESSAGE" != "Hi server, please encrypt me and send to client!" ]; then
  echo "Server symmetric encryption using the exchanged master-key has failed."
  exit 1
else
  echo "Client-Server TLS handshake has been completed successfully"
fi
