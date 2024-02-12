#!/bin/bash

# Specify the folder path on your host machine
HOST_FOLDER_PATH="C:\Users\User\Desktop\DevOps\atech-devops-nov-2023\docker\group_nginx\html"

# Specify the container path where the folder will be mounted
CONTAINER_FOLDER_PATH="/usr/share/nginx/html"

# Send keystrokes to Docker Desktop
screen -S DockerDesktop -X stuff "open -a Docker^M"
sleep 5 # Wait for Docker Desktop to open

# Send keystrokes to Docker Desktop Preferences
screen -S DockerDesktop -X stuff $'tell application "System Events"\nkeystroke "," using {command down}\ndelay 1\nkeystroke "File Sharing"\ndelay 1\nkeystroke tab\ndelay 1\nkeystroke tab\ndelay 1\nkeystroke "$HOST_FOLDER_PATH"\ndelay 1\nkeystroke tab\ndelay 1\nkeystroke "open"\ndelay 1\nkeystroke "close"\ndelay 1\nkeystroke "q" using {command down}\nend tell\n'
