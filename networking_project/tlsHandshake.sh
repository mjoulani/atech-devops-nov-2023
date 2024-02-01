#!/bin/bash

#-----START clienthello section-----
ip_server="3.26.41.143:8080"
json_data=$(curl -X POST -H "Content-Type: application/json" -d '{
  "version": "1.3",
  "ciphersSuites": [
    "TLS_AES_128_GCM_SHA256",
    "TLS_CHACHA20_POLY1305_SHA256"
  ],
  "message": "Client Hello"
}' http://$ip_server/clienthello)

# echo $json_data
version=$(echo "$json_data" | jq -r '.version')
sessionID=$(echo "$json_data" | jq -r '.sessionID')
cipherSuite=$(echo "$json_data" | jq -r '.cipherSuite')
serverCert=$(echo "$json_data" | jq -r '.serverCert')
echo $serverCert>cert.pem
# #-----END clienthello section-----




#-----START verify section-----
status=$(openssl verify -CAfile tls_webserver/cert-ca-aws.pem cert.pem)
if [ "$status" == "cert.pem: OK" ]; then
    echo "OK"
else
    echo "Server Certificate is invalid."
    exit 5
fi
#-----END verify section-----




#-----START generating symmetric key section-----
generatedKey="$(openssl rand -base64 32)"
echo $generatedKey>generatedKey.txt
masterKey="$(openssl smime -encrypt -aes-256-cbc -in generatedKey.txt -outform DER cert.pem | base64 -w 0)"
#-----END generating symmetric key section-----


res_data=$(curl -X POST -H "Content-Type: application/json" -d '{
    "sessionID": "'$sessionID'",
    "masterKey": "'$masterKey'",
    "sampleMessage": "Hi server, please encrypt me and send to client!"
}' http://$ip_server/keyexchange)

encryptedSimpleMsg=$(echo "$res_data" | jq -r '.encryptedSampleMessage')
echo $encryptedSimpleMsg | base64 -d > encSampleMsg.txt
decrypted_message=$(openssl enc -d -aes-256-cbc -pbkdf2 -in encSampleMsg.txt -pass pass:"$generatedKey")




if [ "$decrypted_message" != "Hi server, please encrypt me and send to client!" ]; then
  echo "Server symmetric encryption using the exchanged master-key has failed."
  exit 6
else
  echo "Client-Server TLS handshake has been completed successfully"
fi

# TODO Your solution here