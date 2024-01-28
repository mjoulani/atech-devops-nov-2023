#!/bin/bash

#-----START clienthello section-----
# json_data=$(curl -X POST -H "Content-Type: application/json" -d '{
#   "version": "1.3",
#   "ciphersSuites": [
#     "TLS_AES_128_GCM_SHA256",
#     "TLS_CHACHA20_POLY1305_SHA256"
#   ],
#   "message": "Client Hello"
# }' http://3.26.235.172:8080/clienthello)

# echo $json_data
# version=$(echo "$json_data" | jq -r '.version')
# sessionID=$(echo "$json_data" | jq -r '.sessionID')
# cipherSuite=$(echo "$json_data" | jq -r '.cipherSuite')
# serverCert=$(echo "$json_data" | jq -r '.serverCert')
# #-----END clienthello section-----



# echo $serverCert>cert.pem

status=$(openssl verify -CAfile tls_webserver/cert-ca-aws.pem cert.pem)
echo $status
if [ "$status" == "cert.pem: OK" ]; then
    echo "OK"
else
    echo "Server Certificate is invalid."
    echo "Try again"
    exit 5
fi
# TODO Your solution here