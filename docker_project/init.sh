#!/bin/bash

# Absolute path to ngrok executable
# NGROK_PATH="C:/Users/User/Desktop/DevOps/ngrok"

# Start ngrok to expose a local server (replace 8443 with your desired port)
ngrok http 8443 > ngrok_output.log 2>&1 &

# Wait for a few seconds to allow ngrok to start (adjust as needed)
sleep 5

# Read the ngrok output from the log file and extract the public URL
public_url=$(grep -oE 'Forwarding\s+https?://[^ ]+' ngrok_output.log)

# Print the public URL
echo "Public URL: $public_url"
