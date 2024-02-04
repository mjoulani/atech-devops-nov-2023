#!/bin/bash

# Pull the latest MongoDB image
docker pull mongo:latest

# Run the MongoDB container
docker pull mongodb/mongodb-community-server
docker run --name mongodb -p 27017:27017 -v E:\elements\Devops_Atech\mongo_data:/data/db -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password -d mongo:latest
