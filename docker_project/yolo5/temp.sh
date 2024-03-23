#!/bin/bash

echo "starting"

docker stop flask_app
docker rm flask_app
docker rmi flask_service
docker build -t flask_service ~/atech-devops-nov-2023/docker_project/yolo5/

docker run -p 8081:8081 --name flask_app -v ~/.aws:/root/.aws flask_service

docker ps
