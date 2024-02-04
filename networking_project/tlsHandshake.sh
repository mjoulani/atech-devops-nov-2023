#!/bin/bash

# # Step 1 - Client Hello

#Client Hello HTTP request to the server and save serverCert from the JSON response
curl -X POST \
      http://13.201.31.184:8080/clienthello \
      -H "Content-Type: application/json" \
      -d '{"version":"1.3","ciphersSuites":["TLS_AES_128_GCM_SHA256","TLS_CHACHA20_POLY1305_SHA256"],"message":"Client Hello"}' \
      | jq -r '.serverCert' > cert.pem


#Client Hello HTTP request to the server and save sessionID from the JSON response
curl -X POST \
      http://13.201.31.184:8080/clienthello \
      -H "Content-Type: application/json" \
      -d '{"version":"1.3","ciphersSuites":["TLS_AES_128_GCM_SHA256","TLS_CHACHA20_POLY1305_SHA256"],"message":"Client Hello"}' \
      | jq -r '.sessionID' > sessionID.txt


SESSION_ID=$(cat sessionID.txt)


# download Certificate Authority from Amazon Web Services
wget  https://raw.githubusercontent.com/alonitac/atech-devops-june-2023/main/networking_project/tls_webserver/cert-ca-aws.pem

# Step 2 - Server Certificate Verification
#VERFY=$(openssl verify -CAfile cert-ca-aws.pem cert.pem)
#if [ "$VERFY" != "cert.pem: OK" ]; then
if [ $(openssl verify -CAfile cert-ca-aws.pem cert.pem) != "cert.pem: OK" ]; then
  echo "Server Certificate is invalid. Exiting."
  exit 5
fi

# Step 3 - Generate 32 random bytes base64 string as the master-key
openssl rand -base64 32 > masterKey.txt

# Step 4 - Encrypt the master-key with the server certificate
master_key=$(openssl smime -encrypt -aes-256-cbc -in masterKey.txt -outform DER cert.pem | base64 -w 0)

# # Step 5 - Client-Server master-key exchange
curl -X POST \
      http://13.201.31.184:8080/keyexchange \
      -H "Content-Type: application/json" \
      -d '{"sessionID":"'${SESSION_ID}'","masterKey":"'${master_key}'","sampleMessage":"Hi server, please encrypt me and send to client!"}'\
      | jq -r '.encryptedSampleMessage' > encryptedSampleMessage.txt 

# Parse Key Exchange response
cat encryptedSampleMessage.txt | base64 -d > encSampleMsgReady.txt

# Decrypt the sample message using the master-key
openssl enc -d -aes-256-cbc -pbkdf2  -kfile masterKey.txt -in encSampleMsgReady.txt -out dencryptedSampleMessage.txt

decrypted_sample_message=$(cat dencryptedSampleMessage.txt)

# # Step 6 - Client verification message
if [ "${decrypted_sample_message}" != "Hi server, please encrypt me and send to client!" ]; then
 echo "Server symmetric encryption using the exchanged master-key has failed. Exiting."
 exit 6
 fi

#If everything is ok, print a positive message
 echo "Client-Server TLS handshake has been completed successfully"
