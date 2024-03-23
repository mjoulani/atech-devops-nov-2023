import time
from pathlib import Path
from flask import Flask, request
#from detect import run
import uuid
import yaml
from loguru import logger
import os
import boto3
from pymongo import MongoClient
from pymongo.errors import OperationFailure

# images_bucket = os.environ['BUCKET_NAME']
images_bucket = "qasem-bucket"
image_name = ""
#14225

# connect to s3 and download an img
def download_image_from_s3(image_key):
    s3 = boto3.client('s3')

    global image_name
    image_name = image_key

    local_path = f'{image_key}'
    try:
        s3.download_file(images_bucket, image_key, local_path)
        logger.info(f"Image '{image_key}' downloaded successfully to '{local_path}'")
        return local_path
    except Exception as e:
        logger.info(f"Error downloading image '{image_key}': {e}")


def upload_img_to_s3(image_path, prefix):
    s3 = boto3.client('s3')
    try:
        s3.upload_file(image_path, images_bucket, prefix + image_name)
        logger.info('image uploaded successfuly!')
    except Exception as e:
        logger.info(f"Error downloading image '{image_path}': {e}")


with open("data/coco128.yaml", "r") as stream:
    names = yaml.safe_load(stream)['names']

app = Flask(__name__)


@app.route('/', methods=['GET'])
def index():
    return "the server is working!!"


@app.route('/predict', methods=['POST'])
def predict():
    # Generates a UUID for this current prediction HTTP request. This id can be used as a reference in logs to identify and track individual prediction requests.
    prediction_id = str(uuid.uuid4())

    logger.info(f'prediction: {prediction_id}. start processing')

    # Receives a URL parameter representing the image to download from S3
    img_name = request.args.get('imgName')
    # original_img_path = ...

    # TODO download img_name from S3, store the local image path in original_img_path
    original_img_path = download_image_from_s3(img_name)

    #  The bucket name should be provided as an env var BUCKET_NAME.

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
    upload_img_to_s3(predicted_img_path, "predicted_")

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
            'prediction_id': prediction_id,
            'original_img_path': original_img_path,
            'predicted_img_path': predicted_img_path,
            'labels': labels,
            'time': time.time()
        }

        # TODO store the prediction_summary in MongoDB

        # By Khader: We are here => connect to mongodb and store the data!!!
        replica_set_uri = "mongodb://localhost:27017,localhost:27018,localhost:27019/?replicaSet=myReplicaSet"
        try:
            # Connect to the replica set
            client = MongoClient(replica_set_uri)

            # Create a database
            db = client['yolov3_db']

            # Create a collection
            collection = db['predicted_data']

            collection.insert_one(prediction_summary)

        except  OperationFailure as e:
            print("Error:", e)

        return prediction_summary
    else:
        return f'prediction: {prediction_id}/{original_img_path}. prediction result not found', 404


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8081)