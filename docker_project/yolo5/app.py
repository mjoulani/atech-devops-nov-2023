import time
from pathlib import Path
import boto3
from flask import Flask, request, jsonify
from detect import run
#from detect.sub_module.run import run
import uuid
import yaml
from loguru import logger
import os
import pymongo
import subprocess
from pymongo import MongoClient
from pymongo.errors import ServerSelectionTimeoutError

# Set AWS credentials and region as environment variables
#os.environ["AWS_ACCESS_KEY_ID"] = "AKIA5SPWCQVQKUH5Y2E7"
#os.environ["AWS_SECRET_ACCESS_KEY"] = "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"
#os.environ["AWS_DEFAULT_REGION"] = "ap-northeast-1"

# Function to initiate the MongoDB replica set
def initiate_replica_set():
    # Wait for MongoDB containers to be up and running
    time.sleep(5)

    # Define the replica set name and members
    replica_set_config = {
        "_id": "myReplicaSet",
        "members": [
            {"_id": 0, "host": "mongo1:27017"},
            {"_id": 1, "host": "mongo2:27017"},
            {"_id": 2, "host": "mongo3:27017"}
        ]
    }

    # Execute the MongoDB initiation script
    #cmd = f'mongo mongo1:27017 --eval "rs.initiate({replica_set_config})"'
    cmd = f'/usr/bin/mongo mongo1:27017 --eval "rs.initiate({replica_set_config})"'
    subprocess.run(cmd, shell=True)
    
    
images_bucket = os.environ['BUCKET_NAME']
#images_bucket = os.environ['mjoulani-yolo']

with open("data/coco128.yaml", "r") as stream:
    names = yaml.safe_load(stream)['names']

app = Flask(__name__)


@app.route('/predict', methods=['POST'])
def predict():
    # Generates a UUID for this current prediction HTTP request. This id can be used as a reference in logs to identify and track individual prediction requests.
    prediction_id = str(uuid.uuid4())

    logger.info(f'prediction: {prediction_id}. start processing')

    # Receives a URL parameter representing the image to download from S3
    img_name = request.args.get('imgName')

    # TODO download img_name from S3, store the local image path in original_img_path
    #  The bucket name should be provided as an env var BUCKET_NAME.

    bucket_name = os.getenv('BUCKET_NAME')

    original_img_path = str(img_name)

    s3 = boto3.client('s3')
    s3.download_file(bucket_name, img_name, original_img_path)

    logger.info(f'prediction: {prediction_id}/{original_img_path}. Download img completed')

    # Predicts the objects in the image
    run(
        weights='yolov5s.pt',
        data='data/coco128.yaml',
        source=original_img_path,
        project='static/data',
        name=prediction_id,
        save_txt=True
    )

    logger.info(f'prediction: {prediction_id}/{original_img_path}. done')

    # This is the path for the predicted image with labels
    # The predicted image typically includes bounding boxes drawn around the detected objects, along with class labels and possibly confidence scores.
    predicted_img_path = Path(f'static/data/{prediction_id}/{original_img_path}')

    # TODO Uploads the predicted image (predicted_img_path) to S3 (be careful not to override the original image).

    the_image = original_img_path[:-4] + "_predicted.jpg"
    s3.upload_file(str(predicted_img_path), bucket_name, the_image)

    # Parse prediction labels and create a summary
    pred_summary_path = Path(f'static/data/{prediction_id}/labels/{original_img_path.split(".")[0]}.txt')
    if pred_summary_path.exists():
        with open(pred_summary_path) as f:
            labels = f.read().splitlines()
            labels = [line.split(' ') for line in labels]
            labels = [{
                'class': names[int(l[0])],
                'cx': float(l[1]),
                'cy': float(l[2]),
                'width': float(l[3]),
                'height': float(l[4]),
            } for l in labels]

        logger.info(f'prediction: {prediction_id}/{original_img_path}. prediction summary:\n\n{labels}')

        prediction_summary = {
            'prediction_id': str(prediction_id),
            'original_img_path': original_img_path,
            'predicted_img_path': str(predicted_img_path),
            'labels': labels,
            'time': time.time()
        }

        # Store the prediction_summary in MongoDB
        #client = pymongo.MongoClient("mongodb://mongo1:27017/")
        #client = pymongo.MongoClient('mongodb://mongo1:27017,mongo2:27017,mongo3:27017/?replicaset=rs0')

        # Wait for MongoDB containers to be up and running
        #initiate_replica_set()
        mongo_members = ["mongo1:27017", "mongo2:27017", "mongo3:27017"]
        #mongo_uri = f"mongodb://{'mongodbCluster/,'.join(mongo_members)}/?replicaSet=myReplicaSet"
       

        # Initialize the result variable with a default value
        result = {'ismaster': False}

        # Attempt to connect to MongoDB using the replica set
        for mongo_member in mongo_members:
            try:
                client = pymongo.MongoClient(f"mongodb://{mongo_member}/", serverSelectionTimeoutMS=5000)
                result = client.admin.command('isMaster')
                logger.info(f'the result_inside--------- :{result} ')
                if result['ismaster'] == True:
                    break  # Successfully connected to MongoDB
            except ServerSelectionTimeoutError:
                pass  # Try the next MongoDB member

        # Check if a valid MongoDB connection was established
        logger.info(f'the result--------- :{result} ')
        if result['ismaster'] == False :
            logger.info(f'the result--------- :{result} ')
            error={
                    "prediction_id": " ",
                    "original_img_path": " ",
                    "predicted_img_path": " ",
                    "labels": [
                                {
                                    "class": "No valid MongoDB connection established"
                                }
                            ],
                    "time": " "
                }
            #return jsonify([{'class': 'No valid MongoDB connection established'}]), 500
            return jsonify(error)
        

        db = client["mongodb"]
        collection = db["prediction"]
        
        inserted_id = collection.insert_one(prediction_summary).inserted_id

        # Now convert the ObjectId to str for JSON serialization
        prediction_summary['_id'] = str(inserted_id)

        return jsonify(prediction_summary)

    else:
        return jsonify({'error': f'prediction: {prediction_id}/{original_img_path}. prediction result not found'}), 404


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8081)