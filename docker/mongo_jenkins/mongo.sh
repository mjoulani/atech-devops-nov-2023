#!/bin/bash

# Pull the latest MongoDB image is not necessary
docker pull mongo:latest

# Run the MongoDB container
<<<<<<< HEAD:docker/mongo/mongo.sh
docker run --name mongodb -p 27017:27017 -v /home/yoyoq/mongo_demo\mongo_data:/data/db -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password -d mongo:latest
=======
docker run --name mongodb -p 27017:27017 -v E:\elements\Devops_Atech\mongo_data:/data/db -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password -d  mongo:latest
>>>>>>> origin:docker/mongo_jenkins/mongo.sh
