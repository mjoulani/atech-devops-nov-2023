#!/bin/bash
set -e

# Start MongoDB in the background
mongod --replSet myReplicaSet --bind_ip localhost,mongo1 &

# MongoDB takes a few seconds to start
echo "Waiting for MongoDB to start..."
sleep 10

# Initiate the replica set
mongosh --eval "rs.initiate({
  _id: 'myReplicaSet',
  members: [
    { _id: 0, host: 'mongo1:27017' },
    { _id: 1, host: 'mongo2:27017' },
    { _id: 2, host: 'mongo3:27017' }
  ]
})"

# Keep the script running to prevent the container from exiting
wait